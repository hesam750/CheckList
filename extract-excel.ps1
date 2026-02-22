 $path = (Get-ChildItem -Path . -Filter "MTBF*041115*.xlsx" | Select-Object -First 1).FullName
 if (-not $path) { throw "Excel file not found" }
 Add-Type -AssemblyName System.IO.Compression
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $stream = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
 $zip = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Read, $false)
 function Get-EntryXml($archive, $fullName) {
   $entry = $archive.Entries | Where-Object { $_.FullName -eq $fullName } | Select-Object -First 1
   if (-not $entry) { return $null }
   $reader = New-Object System.IO.StreamReader($entry.Open())
   $xml = [xml]$reader.ReadToEnd()
   $reader.Close()
   return $xml
 }
 function Get-ColumnIndex($letters) {
   $index = 0
   foreach ($ch in $letters.ToCharArray()) {
     $index = $index * 26 + ([int][char]$ch - 64)
   }
   return $index
 }
 $sharedStrings = @()
 $sharedXml = Get-EntryXml $zip "xl/sharedStrings.xml"
 if ($sharedXml -and $sharedXml.sst -and $sharedXml.sst.si) {
   foreach ($si in $sharedXml.sst.si) {
     if ($si.t) {
       $sharedStrings += "$($si.t)"
     } elseif ($si.r) {
       $sharedStrings += (($si.r | ForEach-Object { "$($_.t)" }) -join "")
     } else {
       $sharedStrings += ""
     }
   }
 }
 $workbookXml = Get-EntryXml $zip "xl/workbook.xml"
 $relsXml = Get-EntryXml $zip "xl/_rels/workbook.xml.rels"
 if (-not $workbookXml -or -not $relsXml) { throw "Workbook metadata not found" }
 $relMap = @{}
 foreach ($rel in $relsXml.Relationships.Relationship) {
   $relMap[$rel.Id] = $rel.Target
 }
 $sheetMap = @{}
 $summary = @()
 foreach ($sheet in $workbookXml.workbook.sheets.sheet) {
   $sheetId = $null
   $attr = $sheet.Attributes | Where-Object { $_.Name -eq "r:id" -or ($_.LocalName -eq "id" -and $_.NamespaceURI -match "relationships") } | Select-Object -First 1
   if ($attr) { $sheetId = $attr.Value } elseif ($sheet.'r:id') { $sheetId = $sheet.'r:id' }
   if (-not $sheetId) { continue }
   $target = $relMap[$sheetId]
   if (-not $target) { continue }
   $sheetPath = if ($target -match "^xl/") { $target } else { "xl/$target" }
   $sheetXml = Get-EntryXml $zip $sheetPath
   if (-not $sheetXml -or -not $sheetXml.worksheet.sheetData) { continue }
   $rowsList = New-Object System.Collections.Generic.List[object]
   $maxCol = 0
   $lastRowIndex = 0
   foreach ($rowNode in $sheetXml.worksheet.sheetData.row) {
     $rowIndex = if ($rowNode.r) { [int]$rowNode.r } else { $lastRowIndex + 1 }
     while ($lastRowIndex + 1 -lt $rowIndex) {
       $rowsList.Add(@()) | Out-Null
       $lastRowIndex++
     }
     $lastRowIndex = $rowIndex
     $rowValues = @()
     foreach ($cell in $rowNode.c) {
       $ref = $cell.r
       if (-not $ref) { continue }
       $letters = ($ref -replace "\d", "")
       $colIndex = Get-ColumnIndex $letters
       if ($colIndex -gt $maxCol) { $maxCol = $colIndex }
       $value = $null
       if ($cell.t -eq "s") {
         $idx = [int]$cell.v
         if ($idx -ge 0 -and $idx -lt $sharedStrings.Count) { $value = $sharedStrings[$idx] }
       } elseif ($cell.t -eq "inlineStr") {
         if ($cell.is -and $cell.is.t) { $value = "$($cell.is.t)" }
       } elseif ($cell.t -eq "b") {
         $value = $cell.v -eq "1"
       } else {
         if ($cell.v) { $value = $cell.v }
       }
       $index = $colIndex - 1
       if ($rowValues.Count -le $index) {
         $rowValues += @($null) * ($index - $rowValues.Count + 1)
       }
       $rowValues[$index] = $value
     }
     $rowsList.Add($rowValues) | Out-Null
   }
   for ($i = 0; $i -lt $rowsList.Count; $i++) {
     $row = $rowsList[$i]
     if ($row.Count -lt $maxCol) {
       $row += @($null) * ($maxCol - $row.Count)
     }
     $rowsList[$i] = $row
   }
   $sheetName = $sheet.name
   $sheetMap[$sheetName] = @{ rows = $rowsList.ToArray() }
   $summary += [pscustomobject]@{ name = $sheetName; rows = $rowsList.Count; cols = $maxCol }
 }
 $output = @{ file = $path; sheets = $sheetMap } | ConvertTo-Json -Depth 10
 $output | Set-Content -Encoding UTF8 .\data\excel-data.json
 $summary | ConvertTo-Json -Depth 4 | Write-Output
 $zip.Dispose()
 $stream.Dispose()
