import { NextResponse } from "next/server"
import { overviewKPI } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(overviewKPI)
}
