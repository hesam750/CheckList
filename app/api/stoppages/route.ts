import { NextResponse } from "next/server"
import type { Stoppage, StoppageStatus } from "@/lib/types"
import { db } from "@/lib/db"

type StoppageRow = {
  id: number | string
  code: string | null
  type: string | null
  description: string | null
  start_date: string | null
  start_time: string | null
  end_date: string | null
  end_time: string | null
  shift: string | null
  status: StoppageStatus | null
  unit: string | null
  line: string | null
  machine: string | null
  created_by_id: string | null
  created_by_name: string | null
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const status = searchParams.get("status")
  const unit = searchParams.get("unit")
  const line = searchParams.get("line")
  const machine = searchParams.get("machine")
  const shift = searchParams.get("shift")

  const filters: string[] = []
  const values: (string | null)[] = []
  if (status) {
    values.push(status)
    filters.push(`s.status = $${values.length}`)
  }
  if (unit) {
    values.push(unit)
    filters.push(`u.name = $${values.length}`)
  }
  if (line) {
    values.push(line)
    filters.push(`l.name = $${values.length}`)
  }
  if (machine) {
    values.push(machine)
    filters.push(`m.name = $${values.length}`)
  }
  if (shift) {
    values.push(shift)
    filters.push(`s.shift = $${values.length}`)
  }

  const whereClause = filters.length ? `WHERE ${filters.join(" AND ")}` : ""
  const result = await db.query(
    `SELECT s.id, s.code, s.type, s.description, s.start_date, s.start_time, s.end_date, s.end_time, s.shift, s.status,
            u.name AS unit, l.name AS line, m.name AS machine,
            cu.id AS created_by_id, cu.name AS created_by_name
     FROM stoppages s
     LEFT JOIN units u ON u.id = s.unit_id
     LEFT JOIN lines l ON l.id = s.line_id
     LEFT JOIN machines m ON m.id = s.machine_id
     LEFT JOIN users cu ON cu.id = s.created_by
     ${whereClause}
     ORDER BY s.id DESC`,
    values
  )

  const rows: Stoppage[] = (result.rows as StoppageRow[]).map((row) => {
    const createdBy = row.created_by_name || row.created_by_id || "سیستم"
    const startTime = row.start_time || row.start_date || ""
    const endTime = row.end_time || row.end_date || ""
    return {
      id: String(row.id),
      code: row.code ?? undefined,
      unit: row.unit ?? "نامشخص",
      line: row.line ?? row.unit ?? "نامشخص",
      machine: row.machine ?? "نامشخص",
      shift: row.shift ?? "نامشخص",
      startDate: row.start_date ?? undefined,
      startClock: row.start_time ?? undefined,
      startTime,
      endDate: row.end_date ?? undefined,
      endClock: row.end_time ?? undefined,
      endTime,
      type: row.type ?? "نامشخص",
      cause: row.description ?? row.type ?? "نامشخص",
      description: row.description ?? "ثبت نشده",
      status: row.status ?? "approved",
      createdBy,
      createdAt: row.start_date ?? row.start_time ?? "نامشخص",
    }
  })

  return NextResponse.json(rows)
}

export async function POST(request: Request) {
  const body = (await request.json()) as Partial<Stoppage>
  const requiredFields = [
    "unit",
    "line",
    "machine",
    "shift",
    "startTime",
    "endTime",
    "type",
    "cause",
    "description",
    "createdBy",
  ] as const

  const missingField = requiredFields.find((field) => !body[field])
  if (missingField) {
    return NextResponse.json(
      { error: `فیلد ${missingField} الزامی است.` },
      { status: 400 }
    )
  }

  const unitName = body.unit as string
  const lineName = body.line as string
  const machineName = body.machine as string

  const unitResult = await db.query(
    "SELECT id FROM units WHERE name = $1 LIMIT 1",
    [unitName]
  )
  const unitId = (unitResult.rows[0] as { id?: number } | undefined)?.id
  if (!unitId) {
    return NextResponse.json({ error: "سالن یافت نشد." }, { status: 400 })
  }

  const lineResult = await db.query(
    "SELECT id FROM lines WHERE name = $1 AND unit_id = $2 LIMIT 1",
    [lineName, unitId]
  )
  const lineId = (lineResult.rows[0] as { id?: number } | undefined)?.id
  if (!lineId) {
    return NextResponse.json({ error: "خط تولید یافت نشد." }, { status: 400 })
  }

  const machineResult = await db.query(
    "SELECT id FROM machines WHERE name = $1 AND (line_id = $2 OR unit_id = $3) LIMIT 1",
    [machineName, lineId, unitId]
  )
  const machineId = (machineResult.rows[0] as { id?: number } | undefined)?.id
  if (!machineId) {
    return NextResponse.json({ error: "دستگاه یافت نشد." }, { status: 400 })
  }

  const createdByValue = body.createdBy as string
  const createdByResult = await db.query(
    "SELECT id FROM users WHERE id = $1 OR username = $1 OR name = $1 LIMIT 1",
    [createdByValue]
  )
  const createdById = ((createdByResult.rows[0] as { id?: string } | undefined)?.id ?? null)

  const insertResult = await db.query(
    `INSERT INTO stoppages (
      unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
    ) RETURNING id`,
    [
      unitId,
      lineId,
      machineId,
      body.code ?? null,
      body.type,
      body.description,
      body.startDate ?? null,
      body.startClock ?? body.startTime ?? null,
      body.endDate ?? null,
      body.endClock ?? body.endTime ?? null,
      body.shift,
      "pending_supervisor",
      createdById,
    ]
  )

  const insertedId = (insertResult.rows[0] as { id?: number } | undefined)?.id
  const newStoppage: Stoppage = {
    id: String(insertedId ?? ""),
    unit: unitName,
    line: lineName,
    machine: machineName,
    shift: body.shift as string,
    startDate: body.startDate ?? undefined,
    startClock: body.startClock ?? undefined,
    startTime: body.startTime as string,
    endDate: body.endDate ?? undefined,
    endClock: body.endClock ?? undefined,
    endTime: body.endTime as string,
    type: body.type as string,
    cause: body.cause as string,
    description: body.description as string,
    status: "pending_supervisor",
    createdBy: createdByValue,
    createdAt: body.createdAt ?? new Date().toISOString(),
  }

  return NextResponse.json(newStoppage, { status: 201 })
}
