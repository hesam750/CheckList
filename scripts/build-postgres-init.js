const fs = require("fs")
const path = require("path")
const crypto = require("crypto")

const dataPath = path.join(__dirname, "..", "data", "excel-data.json")
const usersPath = path.join(__dirname, "..", "data", "users.json")
const outputPath = path.join(__dirname, "..", "db", "init.sql")

const raw = fs.readFileSync(dataPath, "utf8")
const data = JSON.parse(raw)
const usersRaw = fs.existsSync(usersPath) ? fs.readFileSync(usersPath, "utf8") : "[]"
const users = Array.isArray(JSON.parse(usersRaw)) ? JSON.parse(usersRaw) : []
const sheets = data.sheets || {}

const normalizeCell = (value) => {
  if (value === null || value === undefined) return null
  if (value === "System.Xml.XmlElement") return null
  return value
}

const toText = (value) => {
  if (value === null || value === undefined) return ""
  return String(value).trim()
}

const toNumber = (value) => {
  if (value === null || value === undefined) return null
  if (typeof value === "number") return value
  const parsed = Number.parseFloat(String(value))
  return Number.isNaN(parsed) ? null : parsed
}

const hashPassword = (password) => {
  const salt = crypto.randomBytes(16).toString("base64")
  const derived = crypto.scryptSync(String(password), salt, 64)
  return `scrypt$${salt}$${derived.toString("base64")}`
}

const pad2 = (value) => value.toString().padStart(2, "0")

const buildClock = (hourValue, minuteValue) => {
  const hour = toNumber(hourValue)
  const minute = toNumber(minuteValue)
  if (hour === null || minute === null) return ""
  return `${pad2(Math.floor(hour))}:${pad2(Math.floor(minute))}`
}

const resolveShift = (timeValue) => {
  const text = toText(timeValue)
  if (!text) return "نامشخص"
  const hourText = text.split(":")[0]
  const hour = Number.parseInt(hourText, 10)
  if (Number.isNaN(hour)) return "نامشخص"
  if (hour >= 7 && hour < 15) return "صبح"
  if (hour >= 15 && hour < 23) return "عصر"
  return "شب"
}

const getRows = (name) => (sheets[name]?.rows ?? []).map((row) => (Array.isArray(row) ? row : []))

const getColumn = (name) => getRows(name).map((row) => normalizeCell(row[0] ?? null))

const buildStoppagesFromHeader = () => {
  const rows = getRows("ورود داده")
  if (!rows.length) return []
  const headerIndex =
    rows.findIndex((row) => toText(row?.[0]) === "ردیف") >= 0
      ? rows.findIndex((row) => toText(row?.[0]) === "ردیف")
      : rows.findIndex((row) => {
          const normalized = row.map((cell) => toText(cell))
          return normalized.includes("کد") && normalized.includes("نوع توقف")
        })
  if (headerIndex < 0) return []
  const headerRow = rows[headerIndex] || []
  const columnMap = new Map()
  headerRow.forEach((value, index) => {
    const key = toText(value)
    if (key) columnMap.set(key, index)
  })
  const getCell = (row, key) => {
    const index = columnMap.get(key)
    if (index === undefined) return null
    return normalizeCell(row[index] ?? null)
  }
  const dataRows = rows.slice(headerIndex + 1)
  return dataRows
    .map((row, index) => {
      const rowId = toText(getCell(row, "ردیف"))
      if (rowId && rowId.toLowerCase().includes("total")) return null
      const unit = toText(getCell(row, "سالن")) || "نامشخص"
      const line = unit
      const machine =
        toText(getCell(row, "دستگاه")) ||
        toText(getCell(row, "توضیح دستگاه")) ||
        "نامشخص"
      const code = toText(getCell(row, "کد"))
      const type = toText(getCell(row, "نوع توقف")) || "نامشخص"
      const description = toText(getCell(row, "شرح توقف")) || "ثبت نشده"
      const startDate = toText(getCell(row, "تاریخ توقف"))
      const startHour = getCell(row, "ساعت توقف2") ?? getCell(row, "ساعت توقف")
      const startMinute = getCell(row, "دقیقه توقف")
      const startClock = buildClock(startHour, startMinute)
      const endDate = toText(getCell(row, "تاریخ پایان توقف"))
      const endHour = getCell(row, "ساعت رفع توقف")
      const endMinute = getCell(row, "دقیقه رفع توقف")
      const endClock = buildClock(endHour, endMinute)
      const shift = resolveShift(startClock)
      return {
        rowIndex: Number.parseInt(rowId, 10) || index + 1,
        unit,
        line,
        machine,
        code: code || null,
        type,
        description,
        startDate: startDate || null,
        startTime: startClock || null,
        endDate: endDate || null,
        endTime: endClock || null,
        shift,
        status: "approved",
      }
    })
    .filter(Boolean)
}

const buildStoppagesFromColumns = () => {
  const unitCol = getColumn("سالن")
  const machineCol = getColumn("ستون دستگاه ها")
  const machineDescCol = getColumn("ستون توضیح دستگاه ها")
  const codeCol = getColumn("ستون کد")
  const typeCol = getColumn("ستون نوع توقف")
  const startDateCol = getColumn("ستون تاریخ توقف")
  const startTimeCol = getColumn("زمان شروع توقف")
  const endDateCol = getColumn("تاریخ پایان توقف")
  const endTimeCol = getColumn("زمان پایان توقف")
  const descriptionCol = getColumn("شرح توقف")
  const rowCount = Math.max(
    unitCol.length,
    machineCol.length,
    machineDescCol.length,
    codeCol.length,
    typeCol.length,
    startDateCol.length,
    startTimeCol.length,
    endDateCol.length,
    endTimeCol.length,
    descriptionCol.length
  )
  const rows = []
  for (let i = 0; i < rowCount; i += 1) {
    const unit = toText(unitCol[i]) || "نامشخص"
    const line = unit
    const machine = toText(machineCol[i]) || toText(machineDescCol[i]) || "نامشخص"
    const code = toText(codeCol[i]) || null
    const type = toText(typeCol[i]) || "نامشخص"
    const description = toText(descriptionCol[i]) || "ثبت نشده"
    const startDate = toText(startDateCol[i]) || null
    const startTime = toText(startTimeCol[i]) || null
    const endDate = toText(endDateCol[i]) || null
    const endTime = toText(endTimeCol[i]) || null
    const shift = resolveShift(startTime)
    if (!unit && !machine && !description) continue
    rows.push({
      rowIndex: i + 1,
      unit,
      line,
      machine,
      code,
      type,
      description,
      startDate,
      startTime,
      endDate,
      endTime,
      shift,
      status: "approved",
    })
  }
  return rows
}

const machineOverrides = new Map(
  [
    {
      code: "AB-UL-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه تخلیه کننده",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-LD-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه بارگیر",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-PR-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه پرینتر",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-AS-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "لحیم کاری هوا (Oven)",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-PP-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه قطعه گذاری",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-PP-02",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه قطعه گذاری",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-IV-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "اینورتر سامسونگ",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-AS-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دوش هوا",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-IC-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "کانوایر",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-CM-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "سیستم تست برد الکترونیکی",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-TC-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "سینی تغییردهنده",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-KN-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خمیرزن",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-RG-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "یخچال",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-RG-02",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "یخچال",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-ML-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "بارگذار برد خام1",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-CN-02",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله واسط2",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-VSP-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "چاپگر چسب/خمیر قلع",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-IM-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین بازرسی چسب/ خمیر قلع",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-CN-03",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله واسط3",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-PP-03",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین قطعه گذاری1",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-PP-04",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین قطعه گذاری2",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-CN-04",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله واسط4",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-AOI-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین بازرسی اتوماتیک  برد1",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-RC-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله تفکیک معیوبی1",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-PP-05",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین قطعه گذاری3",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-TC-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین تعویض سینی قطعات",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-IC-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله بازرسی",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-NO-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین لحیم کاری هوای داغ",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-NG-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه نیتروژن ساز",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-CN-05",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله واسط5",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-SI-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "ماشین بازرسی اتوماتیک  برد2",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-RC-02",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "خط انتقال/نوار نقاله تفکیک معیوبی2",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-MU-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "باربردار برد خام2",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-RL-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "بارگذار حلقه ی قطعه1",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-UP-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "منبع تغذیه بدون وقفه",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-MF-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه کاورکفش اتوماتیک",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-DM-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "میکروسکوپ دیجیتالی",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-SC-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "دستگاه کاورکفش اتوماتیک",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-EP-01",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "تابلوبرق ایستاده  1",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-EP-02",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "تابلوبرق ایستاده  2",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
    {
      code: "AB-EP-03",
      unit: "سالن مونتاژ بردهای الکترونیکی",
      name: "تابلوبرق ایستاده 3",
      mttrTarget: 24,
      mttrBase: 0.2,
      mtbfBase: 360,
      mtbfTarget: 720,
    },
  ].map((item) => [`${item.code}||${item.name}||${item.unit}`, item])
)

const buildMachines = () => {
  const codeCol = getColumn("کد دستگاه")
  const unitCol = getColumn("سالن")
  const nameCol = getColumn("دستگاه")
  const mttrBaseCol = getColumn("مبنا MTTR")
  const mttrTargetCol = getColumn("هدف MTTR")
  const mtbfBaseCol = getColumn("مبنا MTBF")
  const mtbfTargetCol = getColumn("هدف MTBF")
  const rowCount = Math.max(
    codeCol.length,
    unitCol.length,
    nameCol.length,
    mttrBaseCol.length,
    mttrTargetCol.length,
    mtbfBaseCol.length,
    mtbfTargetCol.length
  )
  const rows = []
  for (let i = 0; i < rowCount; i += 1) {
    const code = toText(codeCol[i])
    const unit = toText(unitCol[i]) || "نامشخص"
    const name = toText(nameCol[i])
    if (!name && !code) continue
    const baseMachine = {
      code: code || null,
      unit,
      name: name || "نامشخص",
      mttrBase: toNumber(mttrBaseCol[i]),
      mttrTarget: toNumber(mttrTargetCol[i]),
      mtbfBase: toNumber(mtbfBaseCol[i]),
      mtbfTarget: toNumber(mtbfTargetCol[i]),
    }
    const overrideKey = `${baseMachine.code || ""}||${baseMachine.name}||${baseMachine.unit}`
    const override = machineOverrides.get(overrideKey)
    if (override) {
      rows.push({
        code: override.code,
        unit: override.unit,
        name: override.name,
        mttrBase: override.mttrBase,
        mttrTarget: override.mttrTarget,
        mtbfBase: override.mtbfBase,
        mtbfTarget: override.mtbfTarget,
      })
    } else {
      rows.push(baseMachine)
    }
  }
  return rows
}

const stoppages = (() => {
  const fromHeader = buildStoppagesFromHeader()
  if (fromHeader.length) return fromHeader
  return buildStoppagesFromColumns()
})()

const machines = buildMachines()

const units = new Set()
const lines = new Map()
stoppages.forEach((item) => {
  units.add(item.unit)
  const key = `${item.unit}||${item.line}`
  if (!lines.has(key)) {
    lines.set(key, { unit: item.unit, name: item.line })
  }
})
machines.forEach((item) => units.add(item.unit))

const uniqueMachines = new Map()
machines.forEach((machine) => {
  const key = `${machine.code || ""}||${machine.name}||${machine.unit}`
  if (!uniqueMachines.has(key)) {
    uniqueMachines.set(key, machine)
  }
})

const sqlEscape = (value) => String(value).replace(/'/g, "''")

const sqlText = (value) => {
  const text = toText(value)
  if (!text) return "NULL"
  return `'${sqlEscape(text)}'`
}

const sqlNumber = (value) => {
  const num = toNumber(value)
  return num === null ? "NULL" : String(num)
}

const sql = []
sql.push("BEGIN;")
sql.push(`CREATE TABLE IF NOT EXISTS units (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL
);`)
sql.push(`CREATE TABLE IF NOT EXISTS lines (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  unit_id INTEGER REFERENCES units(id) ON DELETE CASCADE,
  UNIQUE (name, unit_id)
);`)
sql.push(`CREATE TABLE IF NOT EXISTS machines (
  id SERIAL PRIMARY KEY,
  code TEXT,
  name TEXT NOT NULL,
  unit_id INTEGER REFERENCES units(id) ON DELETE SET NULL,
  line_id INTEGER REFERENCES lines(id) ON DELETE SET NULL,
  mttr_base NUMERIC,
  mttr_target NUMERIC,
  mtbf_base NUMERIC,
  mtbf_target NUMERIC
);`)
sql.push(`CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  unit TEXT
);`)
sql.push(`CREATE TABLE IF NOT EXISTS permissions (
  id SERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL
);`)
sql.push(`CREATE TABLE IF NOT EXISTS user_permissions (
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, permission_id)
);`)
sql.push(`CREATE TABLE IF NOT EXISTS user_actions (
  id SERIAL PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity TEXT,
  entity_id TEXT,
  payload JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);`)
sql.push(`CREATE TABLE IF NOT EXISTS stoppages (
  id SERIAL PRIMARY KEY,
  row_index INTEGER,
  unit_id INTEGER REFERENCES units(id) ON DELETE SET NULL,
  line_id INTEGER REFERENCES lines(id) ON DELETE SET NULL,
  machine_id INTEGER REFERENCES machines(id) ON DELETE SET NULL,
  code TEXT,
  type TEXT,
  description TEXT,
  start_date TEXT,
  start_time TEXT,
  end_date TEXT,
  end_time TEXT,
  shift TEXT,
  status TEXT,
  created_by TEXT REFERENCES users(id) ON DELETE SET NULL,
  approved_by TEXT REFERENCES users(id) ON DELETE SET NULL
);`)

Array.from(units)
  .filter(Boolean)
  .forEach((unit) => {
    sql.push(`INSERT INTO units (name) VALUES (${sqlText(unit)}) ON CONFLICT (name) DO NOTHING;`)
  })

Array.from(lines.values()).forEach((line) => {
  sql.push(`INSERT INTO lines (name, unit_id)
VALUES (
  ${sqlText(line.name)},
  (SELECT id FROM units WHERE name = ${sqlText(line.unit)} LIMIT 1)
) ON CONFLICT (name, unit_id) DO NOTHING;`)
})

users.forEach((user) => {
  const hashedPassword = hashPassword(user.password ?? "")
  sql.push(
    `INSERT INTO users (id, name, username, password, role, unit)
VALUES (
  ${sqlText(user.id)},
  ${sqlText(user.name)},
  ${sqlText(user.username)},
  ${sqlText(hashedPassword)},
  ${sqlText(user.role)},
  ${sqlText(user.unit)}
) ON CONFLICT (id) DO NOTHING;`
  )
})

const permissionKeys = new Set()
users.forEach((user) => {
  if (Array.isArray(user.permissions)) {
    user.permissions.forEach((perm) => permissionKeys.add(perm))
  }
})
Array.from(permissionKeys).forEach((perm) => {
  sql.push(`INSERT INTO permissions (key) VALUES (${sqlText(perm)}) ON CONFLICT (key) DO NOTHING;`)
})
users.forEach((user) => {
  if (!Array.isArray(user.permissions)) return
  user.permissions.forEach((perm) => {
    sql.push(`INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  ${sqlText(user.id)},
  (SELECT id FROM permissions WHERE key = ${sqlText(perm)} LIMIT 1)
) ON CONFLICT DO NOTHING;`)
  })
})

Array.from(uniqueMachines.values()).forEach((machine) => {
  sql.push(
    `INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  ${sqlText(machine.code)},
  ${sqlText(machine.name)},
  (SELECT id FROM units WHERE name = ${sqlText(machine.unit)} LIMIT 1),
  (SELECT id FROM lines WHERE name = ${sqlText(machine.unit)} AND unit_id = (SELECT id FROM units WHERE name = ${sqlText(machine.unit)} LIMIT 1) LIMIT 1),
  ${sqlNumber(machine.mttrBase)},
  ${sqlNumber(machine.mttrTarget)},
  ${sqlNumber(machine.mtbfBase)},
  ${sqlNumber(machine.mtbfTarget)}
);`
  )
})

stoppages.forEach((item) => {
  const machineLookup = item.code
    ? `(SELECT id FROM machines WHERE code = ${sqlText(item.code)} LIMIT 1)`
    : `(SELECT id FROM machines WHERE name = ${sqlText(item.machine)} LIMIT 1)`
  sql.push(
    `INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  ${Number.isFinite(item.rowIndex) ? item.rowIndex : "NULL"},
  (SELECT id FROM units WHERE name = ${sqlText(item.unit)} LIMIT 1),
  (SELECT id FROM lines WHERE name = ${sqlText(item.line)} AND unit_id = (SELECT id FROM units WHERE name = ${sqlText(item.unit)} LIMIT 1) LIMIT 1),
  ${machineLookup},
  ${sqlText(item.code)},
  ${sqlText(item.type)},
  ${sqlText(item.description)},
  ${sqlText(item.startDate)},
  ${sqlText(item.startTime)},
  ${sqlText(item.endDate)},
  ${sqlText(item.endTime)},
  ${sqlText(item.shift)},
  ${sqlText(item.status)},
  NULL,
  NULL
);`
  )
})

sql.push("COMMIT;")

fs.mkdirSync(path.dirname(outputPath), { recursive: true })
fs.writeFileSync(outputPath, `${sql.join("\n")}\n`, "utf8")

const summary = {
  units: units.size,
  lines: lines.size,
  machines: uniqueMachines.size,
  stoppages: stoppages.length,
  users: users.length,
  permissions: permissionKeys.size,
  output: outputPath,
}
console.log(JSON.stringify(summary, null, 2))
