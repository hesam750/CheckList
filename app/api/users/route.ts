import { NextResponse } from "next/server"
import { mockUsers } from "@/lib/mock-data"

export function GET() {
  return NextResponse.json(mockUsers)
}
