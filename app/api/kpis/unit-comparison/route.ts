import { NextResponse } from "next/server"
import { unitComparisonData } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(unitComparisonData)
}
