import { NextResponse } from "next/server"
import { stoppageCauses } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(stoppageCauses)
}
