const fs = require("fs")
const path = require("path")

const dataPath = path.join(__dirname, "..", "data", "excel-data.json")
const txtPath = path.join(__dirname, "..", "data.txt")
const txt2Path = path.join(__dirname, "..", "data2.txt")

const readTextFile = (filePath) => {
  if (!fs.existsSync(filePath)) {
    return ""
  }
  const buffer = fs.readFileSync(filePath)
  const sampleSize = Math.min(buffer.length, 2000)
  const looksLikeUtf16Le = () => {
    if (sampleSize < 4) return false
    let zeroCount = 0
    let total = 0
    for (let i = 1; i < sampleSize; i += 2) {
      if (buffer[i] === 0x00) zeroCount += 1
      total += 1
    }
    return total > 0 && zeroCount / total > 0.2
  }
  const looksLikeUtf16Be = () => {
    if (sampleSize < 4) return false
    let zeroCount = 0
    let total = 0
    for (let i = 0; i < sampleSize; i += 2) {
      if (buffer[i] === 0x00) zeroCount += 1
      total += 1
    }
    return total > 0 && zeroCount / total > 0.2
  }
  let content = ""
  if (buffer.length >= 2 && buffer[0] === 0xff && buffer[1] === 0xfe) {
    content = buffer.toString("utf16le")
  } else if (buffer.length >= 2 && buffer[0] === 0xfe && buffer[1] === 0xff) {
    content = Buffer.from(buffer).swap16().toString("utf16le")
  } else if (looksLikeUtf16Le()) {
    content = buffer.toString("utf16le")
  } else if (looksLikeUtf16Be()) {
    content = Buffer.from(buffer).swap16().toString("utf16le")
  } else {
    content = buffer.toString("utf8")
  }
  return content.replace(/^\uFEFF/, "")
}

const raw = readTextFile(txtPath)
const raw2 = readTextFile(txt2Path)

const normalizeCell = (value) =>
  String(value ?? "")
    .replace(/[\u200f\u200e]/g, "")
    .replace(/\u00a0/g, " ")
    .trim()

const parseTsv = (input) => {
  const rows = []
  let row = []
  let field = ""
  let inQuotes = false
  for (let i = 0; i < input.length; i += 1) {
    const char = input[i]
    if (char === '"') {
      if (inQuotes && input[i + 1] === '"') {
        field += '"'
        i += 1
      } else {
        inQuotes = !inQuotes
      }
      continue
    }
    if (!inQuotes && (char === "\n" || char === "\r")) {
      if (char === "\r" && input[i + 1] === "\n") {
        i += 1
      }
      row.push(field)
      rows.push(row)
      row = []
      field = ""
      continue
    }
    if (!inQuotes && char === "\t") {
      row.push(field)
      field = ""
      continue
    }
    field += char
  }
  row.push(field)
  rows.push(row)
  return rows
}

const buildSheetFromTable = (tableRows) => {
  const normalizedRows = tableRows.map((row) =>
    row.map((cell) => normalizeCell(cell))
  )

  const headerIndex = normalizedRows.findIndex((row) =>
    row.some((cell) =>
      ["ردیف", "سالن", "دستگاه", "توضیح دستگاه"].includes(cell)
    )
  )

  const fallbackHeaderIndex = normalizedRows.findIndex((row) =>
    row.some((cell) => cell === "کد")
  )

  const resolvedHeaderIndex =
    headerIndex >= 0 ? headerIndex : fallbackHeaderIndex
  if (resolvedHeaderIndex < 0) {
    throw new Error("Header row not found")
  }
  const headerRow = tableRows[resolvedHeaderIndex].map((cell) =>
    normalizeCell(cell)
  )
  const headerLength = headerRow.length
  const dataRows = tableRows
    .slice(resolvedHeaderIndex + 1)
    .filter((row) => row.some((cell) => String(cell ?? "").trim() !== ""))
    .map((row) => {
      const normalized = row.map((cell) => normalizeCell(cell))
      if (normalized.length < headerLength) {
        return normalized.concat(Array(headerLength - normalized.length).fill(""))
      }
      return normalized.slice(0, headerLength)
    })
  return [headerRow, ...dataRows]
}

const readJsonFile = (filePath) => {
  const rawJson = fs.readFileSync(filePath, "utf8")
  const cleaned = rawJson.replace(/^\uFEFF/, "").replace(/\u0000/g, "").trim()
  if (!cleaned) {
    return { sheets: {} }
  }
  try {
    const parsed = JSON.parse(cleaned)
    if (!parsed.sheets || typeof parsed.sheets !== "object") {
      parsed.sheets = {}
    }
    return parsed
  } catch {
    return { sheets: {} }
  }
}

const data = readJsonFile(dataPath)

if (!raw.trim()) {
  throw new Error("data.txt is empty")
}

const rows = parseTsv(raw)
const outputRows = buildSheetFromTable(rows)
data.sheets["ورود داده"] = { rows: outputRows }

if (raw2.trim()) {
  const rows2 = parseTsv(raw2)
  const headerIndex2 = rows2.findIndex((row) =>
    row.some((cell) => normalizeCell(cell) === "کد دستگاه")
  )
  if (headerIndex2 < 0) {
    throw new Error("Machines header not found")
  }
  const headerRow2 = rows2[headerIndex2].map((cell) => normalizeCell(cell))
  const dataRows2 = rows2
    .slice(headerIndex2 + 1)
    .filter((row) => row.some((cell) => String(cell ?? "").trim() !== ""))
    .map((row) => row.map((cell) => normalizeCell(cell)))

  const getColIndex = (name) => headerRow2.findIndex((cell) => cell === name)
  const columns = [
    "کد دستگاه",
    "سالن",
    "دستگاه",
    "مبنا MTTR",
    "هدف MTTR",
    "مبنا MTBF",
    "هدف MTBF",
  ]

  for (const colName of columns) {
    const idx = getColIndex(colName)
    if (idx < 0) {
      throw new Error(`Column not found: ${colName}`)
    }
    const colRows = dataRows2.map((row) => [normalizeCell(row[idx])])
    data.sheets[colName] = { rows: colRows }
  }
}

fs.writeFileSync(dataPath, JSON.stringify(data, null, 2), "utf8")
console.log(JSON.stringify({ stoppages: outputRows.length - 1 }, null, 2))
