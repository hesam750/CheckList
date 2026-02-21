import { NextResponse } from "next/server"
import { createAccessToken, createRefreshToken, setAuthCookies } from "@/lib/auth"
import { getAuthUserByCredentials, toPublicUser } from "@/lib/auth-data"

export async function POST(request: Request) {
  const body = await request.json().catch(() => null)
  const username = body?.username?.trim()
  const password = body?.password

  if (!username || !password) {
    return NextResponse.json(
      { message: "نام کاربری و رمز عبور الزامی است" },
      { status: 400 }
    )
  }

  const user = await getAuthUserByCredentials(username, password)
  if (!user) {
    return NextResponse.json(
      { message: "نام کاربری یا رمز عبور نادرست است" },
      { status: 401 }
    )
  }

  const accessToken = await createAccessToken(user)
  const refreshToken = await createRefreshToken(user)
  const response = NextResponse.json({ user: toPublicUser(user) })

  return setAuthCookies(response, { accessToken, refreshToken })
}
