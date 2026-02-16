import { NextResponse } from "next/server"
import { units } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(units)
}
