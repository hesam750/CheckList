import { NextResponse } from "next/server"
import {
  addAuthUser,
  deleteAuthUser,
  getAllAuthUsers,
  updateAuthUser,
  updateUserPermissions,
} from "@/lib/auth-data"
import type { Permission, UserRole } from "@/lib/types"

export async function GET() {
  return NextResponse.json(await getAllAuthUsers())
}

export async function POST(request: Request) {
  const body = await request.json().catch(() => null)
  const name = body?.name as string | undefined
  const username = body?.username as string | undefined
  const password = body?.password as string | undefined
  const role = body?.role as UserRole | undefined
  const unit = body?.unit as string | undefined

  if (!name || !username || !password || !role || !unit) {
    return NextResponse.json({ message: "اطلاعات کاربر کامل نیست" }, { status: 400 })
  }

  const created = await addAuthUser({ name, username, password, role, unit })
  if (!created) {
    return NextResponse.json({ message: "نام کاربری تکراری است" }, { status: 409 })
  }

  return NextResponse.json({ user: created })
}

export async function PUT(request: Request) {
  const body = await request.json().catch(() => null)
  const id = body?.id as string | undefined
  const permissions = body?.permissions as Permission[] | undefined
  const name = body?.name as string | undefined
  const username = body?.username as string | undefined
  const password = body?.password as string | undefined
  const role = body?.role as UserRole | undefined
  const unit = body?.unit as string | undefined

  if (!id) {
    return NextResponse.json({ message: "درخواست نامعتبر است" }, { status: 400 })
  }

  const hasProfileFields = Boolean(name || username || password || role || unit)
  if (Array.isArray(permissions) && !hasProfileFields) {
    const updated = await updateUserPermissions(id, permissions)
    if (!updated) {
      return NextResponse.json({ message: "کاربر یافت نشد" }, { status: 404 })
    }
    return NextResponse.json({ success: true })
  }

  const updated = await updateAuthUser({ id, name, username, password, role, unit, permissions })
  if (!updated) {
    return NextResponse.json({ message: "کاربر یافت نشد یا نام کاربری تکراری است" }, { status: 409 })
  }
  return NextResponse.json({ user: updated })
}

export async function DELETE(request: Request) {
  const body = await request.json().catch(() => null)
  const id = body?.id as string | undefined
  if (!id) {
    return NextResponse.json({ message: "درخواست نامعتبر است" }, { status: 400 })
  }
  const deleted = await deleteAuthUser(id)
  if (!deleted) {
    return NextResponse.json({ message: "کاربر یافت نشد" }, { status: 404 })
  }
  return NextResponse.json({ success: true })
}
