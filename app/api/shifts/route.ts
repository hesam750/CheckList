import { NextResponse } from "next/server"
import { shifts } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(shifts)
}
