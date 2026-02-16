import { NextResponse } from "next/server"
import { monthlyKPIData } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(monthlyKPIData)
}
