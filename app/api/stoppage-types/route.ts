import { NextResponse } from "next/server"
import { stoppageTypes } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(stoppageTypes)
}
