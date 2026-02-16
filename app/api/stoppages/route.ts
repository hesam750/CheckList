import { NextResponse } from "next/server"
import { mockStoppages } from "@/lib/mock-data"
import type { Stoppage } from "@/lib/types"

const stoppageStore: Stoppage[] = [...mockStoppages]

export function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const status = searchParams.get("status")
  const unit = searchParams.get("unit")
  const line = searchParams.get("line")
  const machine = searchParams.get("machine")
  const shift = searchParams.get("shift")

  const filtered = stoppageStore.filter((stoppage) => {
    if (status && stoppage.status !== status) return false
    if (unit && stoppage.unit !== unit) return false
    if (line && stoppage.line !== line) return false
    if (machine && stoppage.machine !== machine) return false
    if (shift && stoppage.shift !== shift) return false
    return true
  })

  return NextResponse.json(filtered)
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

  const newStoppage: Stoppage = {
    id: crypto.randomUUID(),
    unit: body.unit as string,
    line: body.line as string,
    machine: body.machine as string,
    shift: body.shift as string,
    startTime: body.startTime as string,
    endTime: body.endTime as string,
    type: body.type as string,
    cause: body.cause as string,
    description: body.description as string,
    status: "pending_supervisor",
    createdBy: body.createdBy as string,
    createdAt: body.createdAt ?? new Date().toISOString(),
  }

  stoppageStore.unshift(newStoppage)
  return NextResponse.json(newStoppage, { status: 201 })
}
