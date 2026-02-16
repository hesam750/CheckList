import { NextResponse } from "next/server"
import { causeParetoData } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(causeParetoData)
}
