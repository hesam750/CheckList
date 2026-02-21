import type { Stoppage, Unit, KPIData } from "./types"
import excelData from "@/data/excel-data.json"

type ExcelSheet = { rows: (string | number | null)[][] }
type ExcelData = { sheets?: Record<string, ExcelSheet> }

const data = excelData as ExcelData
const rows = data.sheets?.["ورود داده"]?.rows ?? []
const headerIndex = rows.findIndex((row) => row?.[0] === "ردیف")
const headerRow = headerIndex >= 0 ? rows[headerIndex] : []
const columnMap = new Map<string, number>()
headerRow.forEach((value, index) => {
  if (typeof value === "string" && value.trim()) {
    columnMap.set(value.trim(), index)
  }
})

const normalizeCell = (value: string | number | null | undefined) => {
  if (value === null || value === undefined) return null
  if (value === "System.Xml.XmlElement") return null
  return value
}

const getCell = (row: (string | number | null)[], key: string) => {
  const index = columnMap.get(key)
  if (index === undefined) return null
  return normalizeCell(row[index] ?? null)
}

const toText = (value: string | number | null) => {
  if (value === null || value === undefined) return ""
  return String(value).trim()
}

const toNumber = (value: string | number | null) => {
  if (value === null || value === undefined) return null
  if (typeof value === "number") return value
  const parsed = Number.parseFloat(value)
  return Number.isNaN(parsed) ? null : parsed
}

const pad2 = (value: number) => value.toString().padStart(2, "0")

const buildClock = (hourValue: string | number | null, minuteValue: string | number | null) => {
  const hour = toNumber(hourValue)
  const minute = toNumber(minuteValue)
  if (hour === null || minute === null) return ""
  return `${pad2(Math.floor(hour))}:${pad2(Math.floor(minute))}`
}

const buildTime = (dateValue: string | number | null, clockValue: string) => {
  const date = toText(dateValue)
  if (!date && !clockValue) return ""
  if (!date) return clockValue
  if (!clockValue) return date
  return `${date} ${clockValue}`
}

const resolveShift = (hourValue: string | number | null) => {
  const hour = toNumber(hourValue)
  if (hour === null) return "نامشخص"
  if (hour >= 7 && hour < 15) return "صبح"
  if (hour >= 15 && hour < 23) return "عصر"
  return "شب"
}

const toYearFromDate = (value: string) => {
  const parts = value.split("/")
  if (parts.length < 1) return null
  const year = Number.parseInt(parts[0], 10)
  return Number.isNaN(year) ? null : year
}

const toMonthFromDate = (value: string) => {
  const parts = value.split("/")
  if (parts.length < 2) return null
  const month = Number.parseInt(parts[1], 10)
  return Number.isNaN(month) ? null : month
}

const getRowYear = (row: (string | number | null)[]) => {
  const yearValue = toNumber(getCell(row, "سال رفع توقف"))
  if (yearValue !== null) return Math.floor(yearValue)
  const endDate = toText(getCell(row, "تاریخ پایان توقف"))
  const startDate = toText(getCell(row, "تاریخ توقف"))
  return toYearFromDate(endDate) ?? toYearFromDate(startDate)
}

const getRowMonth = (row: (string | number | null)[]) => {
  const monthValue = toNumber(getCell(row, "ماه رفع توقف")) ?? toNumber(getCell(row, "ماه توقف"))
  if (monthValue !== null) return Math.floor(monthValue)
  const endDate = toText(getCell(row, "تاریخ پایان توقف"))
  const startDate = toText(getCell(row, "تاریخ توقف"))
  return toMonthFromDate(endDate) ?? toMonthFromDate(startDate)
}

const dataRows = headerIndex >= 0 ? rows.slice(headerIndex + 1) : []

const machineTargetMap = new Map<string, { mtbfTarget: number; mttrTarget: number }>()
dataRows.forEach((row) => {
  const machineName =
    toText(getCell(row, "دستگاه")) ||
    toText(getCell(row, "توضیح دستگاه"))
  if (!machineName) return
  const mtbfTarget = toNumber(getCell(row, "هدف MTBF")) ?? 0
  const mttrTarget = toNumber(getCell(row, "هدف MTTR")) ?? 0
  if (!machineTargetMap.has(machineName)) {
    machineTargetMap.set(machineName, { mtbfTarget, mttrTarget })
    return
  }
  const existing = machineTargetMap.get(machineName)!
  machineTargetMap.set(machineName, {
    mtbfTarget: Math.max(existing.mtbfTarget, mtbfTarget),
    mttrTarget: Math.max(existing.mttrTarget, mttrTarget),
  })
})

const stoppages: Stoppage[] = dataRows.reduce<Stoppage[]>((acc, row, index) => {
  const rowId = toText(getCell(row, "ردیف"))
  if (!rowId || rowId.toLowerCase().includes("total")) return acc
  const unit = toText(getCell(row, "سالن")) || "نامشخص"
  const machine =
    toText(getCell(row, "دستگاه")) ||
    toText(getCell(row, "توضیح دستگاه")) ||
    "نامشخص"
  const line = unit
  const code = toText(getCell(row, "کد"))
  const type = toText(getCell(row, "نوع توقف")) || "نامشخص"
  const description = toText(getCell(row, "شرح توقف"))
  const cause = description || type
  const startDate = toText(getCell(row, "تاریخ توقف"))
  const startHour = getCell(row, "ساعت توقف2") ?? getCell(row, "ساعت توقف")
  const startMinute = getCell(row, "دقیقه توقف")
  const startClock = buildClock(startHour, startMinute)
  const startTime = buildTime(startDate, startClock)
  const endDate = toText(getCell(row, "تاریخ پایان توقف"))
  const endHour = getCell(row, "ساعت رفع توقف")
  const endMinute = getCell(row, "دقیقه رفع توقف")
  const endClock = buildClock(endHour, endMinute)
  const endTime = buildTime(endDate, endClock)
  const durationMinutes = toNumber(getCell(row, "TTR(mints)")) ?? undefined
  const createdAt = startTime || startDate
  acc.push({
    id: `s-${rowId || index + 1}`,
    code: code || undefined,
    unit,
    line,
    machine,
    shift: resolveShift(startHour),
    startDate: startDate || undefined,
    startClock: startClock || undefined,
    startTime,
    endDate: endDate || undefined,
    endClock: endClock || undefined,
    endTime,
    durationMinutes,
    type,
    cause,
    description: description || "ثبت نشده",
    status: "approved",
    createdBy: "سیستم اکسل",
    createdAt: createdAt || "نامشخص",
  })
  return acc
}, [])

const unitMap = new Map<string, Unit>()
stoppages.forEach((stoppage) => {
  const unitName = stoppage.unit
  if (!unitMap.has(unitName)) {
    unitMap.set(unitName, {
      id: `u${unitMap.size + 1}`,
      name: unitName,
      lines: [],
    })
  }
  const unit = unitMap.get(unitName)!
  const lineName = stoppage.line || unitName
  let line = unit.lines.find((item) => item.name === lineName)
  if (!line) {
    line = {
      id: `l${unit.lines.length + 1}`,
      name: lineName,
      unitId: unit.id,
      machines: [],
    }
    unit.lines.push(line)
  }
  const machineName = stoppage.machine || "نامشخص"
  if (!line.machines.some((machine) => machine.name === machineName)) {
    const targets = machineTargetMap.get(machineName)
    const mtbfTarget = targets?.mtbfTarget ?? 0
    const mttrTarget = targets?.mttrTarget ?? 0
    line.machines.push({
      id: `m${line.machines.length + 1}`,
      name: machineName,
      lineId: line.id,
      mtbfTarget,
      mttrTarget,
    })
  }
})

export const units: Unit[] = Array.from(unitMap.values())

export const mockStoppages: Stoppage[] = stoppages

export const shifts = Array.from(
  new Set(stoppages.map((stoppage) => stoppage.shift).filter(Boolean))
)

export const stoppageTypes = Array.from(
  new Set(stoppages.map((stoppage) => stoppage.type).filter(Boolean))
)

export const stoppageCauses = Array.from(
  new Set(stoppages.map((stoppage) => stoppage.cause).filter(Boolean))
)

const monthNames = [
  "فروردین",
  "اردیبهشت",
  "خرداد",
  "تیر",
  "مرداد",
  "شهریور",
  "مهر",
  "آبان",
  "آذر",
  "دی",
  "بهمن",
  "اسفند",
]

const rowYears = dataRows.map((row) => getRowYear(row)).filter((year): year is number => year !== null)
const latestYear = rowYears.length ? Math.max(...rowYears) : null
const monthGroups = new Map<string, { mttrValues: number[]; mtbfValues: number[]; downtime: number; count: number }>()

dataRows.forEach((row) => {
  const rowYear = getRowYear(row)
  if (latestYear !== null && rowYear !== latestYear) return
  const monthValue = getRowMonth(row)
  if (monthValue === null) return
  const monthIndex = Math.floor(monthValue) - 1
  const monthLabel = monthNames[monthIndex] ?? "نامشخص"
  if (!monthGroups.has(monthLabel)) {
    monthGroups.set(monthLabel, { mttrValues: [], mtbfValues: [], downtime: 0, count: 0 })
  }
  const group = monthGroups.get(monthLabel)!
  const mttrValue = toNumber(getCell(row, "TTR(mints)"))
  if (mttrValue !== null) {
    group.mttrValues.push(mttrValue)
    group.downtime += mttrValue
  }
  const mtbfValue = toNumber(getCell(row, "TBF(hours)"))
  if (mtbfValue !== null) {
    group.mtbfValues.push(mtbfValue * 60)
  }
  group.count += 1
})

export const monthlyKPIData = Array.from(monthGroups.entries()).map(([month, group]) => {
  const mttr = group.count ? Math.round(group.downtime / group.count) : 0
  const mtbf =
    group.mtbfValues.length > 0
      ? Math.round(group.mtbfValues.reduce((sum, v) => sum + v, 0) / group.mtbfValues.length)
      : 0
  return {
    month,
    mtbf,
    mttr,
    stoppages: group.count,
    downtime: Math.round(group.downtime),
  }
})

const unitGroups = new Map<string, { mttrValues: number[]; mtbfValues: number[] }>()
stoppages.forEach((stoppage) => {
  if (!unitGroups.has(stoppage.unit)) {
    unitGroups.set(stoppage.unit, { mttrValues: [], mtbfValues: [] })
  }
  const group = unitGroups.get(stoppage.unit)!
  if (stoppage.durationMinutes !== undefined) {
    group.mttrValues.push(stoppage.durationMinutes)
  }
})

dataRows.forEach((row) => {
  const unitName = toText(getCell(row, "سالن")) || "نامشخص"
  if (!unitGroups.has(unitName)) {
    unitGroups.set(unitName, { mttrValues: [], mtbfValues: [] })
  }
  const group = unitGroups.get(unitName)!
  const mtbfValue = toNumber(getCell(row, "TBF(hours)"))
  if (mtbfValue !== null) {
    group.mtbfValues.push(mtbfValue * 60)
  }
})

export const unitComparisonData = Array.from(unitGroups.entries()).map(([unit, group]) => {
  const mttr = group.mttrValues.length
    ? Math.round(group.mttrValues.reduce((sum, v) => sum + v, 0) / group.mttrValues.length)
    : 0
  const mtbf =
    group.mtbfValues.length > 0
      ? Math.round(group.mtbfValues.reduce((sum, v) => sum + v, 0) / group.mtbfValues.length)
      : 0
  const availability = mtbf + mttr > 0 ? Number(((mtbf / (mtbf + mttr)) * 100).toFixed(1)) : 0
  return { unit, mtbf, mttr, availability }
})

const causeGroups = new Map<string, { count: number; totalMinutes: number }>()
stoppages.forEach((stoppage) => {
  const key = stoppage.cause || "نامشخص"
  if (!causeGroups.has(key)) {
    causeGroups.set(key, { count: 0, totalMinutes: 0 })
  }
  const group = causeGroups.get(key)!
  group.count += 1
  group.totalMinutes += stoppage.durationMinutes ?? 0
})

const totalCauseCount = Array.from(causeGroups.values()).reduce((sum, item) => sum + item.count, 0)

export const causeParetoData = Array.from(causeGroups.entries())
  .map(([cause, values]) => ({
    cause,
    count: values.count,
    totalMinutes: Math.round(values.totalMinutes),
    percentage: totalCauseCount ? Math.round((values.count / totalCauseCount) * 100) : 0,
  }))
  .sort((a, b) => b.count - a.count)

const totalDowntime = stoppages.reduce((sum, item) => sum + (item.durationMinutes ?? 0), 0)
const totalStoppages = stoppages.length
const mttr = totalStoppages ? Math.round(totalDowntime / totalStoppages) : 0
const mtbfValues = dataRows
  .map((row) => toNumber(getCell(row, "TBF(hours)")))
  .filter((value): value is number => value !== null)
const mtbf = mtbfValues.length
  ? Math.round((mtbfValues.reduce((sum, v) => sum + v, 0) / mtbfValues.length) * 60)
  : 0
const availability = mtbf + mttr > 0 ? Number(((mtbf / (mtbf + mttr)) * 100).toFixed(1)) : 0
const mtbfTargets = dataRows
  .map((row) => toNumber(getCell(row, "هدف MTBF")))
  .filter((value): value is number => value !== null)
const mttrTargets = dataRows
  .map((row) => toNumber(getCell(row, "هدف MTTR")))
  .filter((value): value is number => value !== null)

export const overviewKPI: KPIData = {
  mtbf,
  mttr,
  availability,
  totalStoppages,
  totalDowntime: Math.round(totalDowntime),
  mtbfTarget: mtbfTargets.length
    ? Math.round(mtbfTargets.reduce((sum, v) => sum + v, 0) / mtbfTargets.length)
    : 0,
  mttrTarget: mttrTargets.length
    ? Math.round(mttrTargets.reduce((sum, v) => sum + v, 0) / mttrTargets.length)
    : 0,
}
