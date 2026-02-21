import { NextResponse } from "next/server"
import {
  ACCESS_COOKIE,
  REFRESH_COOKIE,
  createAccessToken,
  createRefreshToken,
  setAuthCookies,
  verifyRefreshToken,
} from "@/lib/auth"
import { getAuthUserById, toPublicUser } from "@/lib/auth-data"

export async function POST(request: Request) {
  const cookies = request.headers.get("cookie") ?? ""
  const refreshToken = cookies
    .split(";")
    .map((item) => item.trim())
    .find((item) => item.startsWith(`${REFRESH_COOKIE}=`))
    ?.split("=")[1]

  if (!refreshToken) {
    return NextResponse.json({ message: "توکن نامعتبر است" }, { status: 401 })
  }

  try {
    const payload = await verifyRefreshToken(refreshToken)
    const userId = payload.sub as string | undefined
    const user = userId ? await getAuthUserById(userId) : undefined
    if (!user) {
      return NextResponse.json({ message: "توکن نامعتبر است" }, { status: 401 })
    }

    const accessToken = await createAccessToken(user)
    const newRefreshToken = await createRefreshToken(user)
    const response = NextResponse.json({ user: toPublicUser(user) })

    return setAuthCookies(response, { accessToken, refreshToken: newRefreshToken })
  } catch {
    const response = NextResponse.json({ message: "توکن نامعتبر است" }, { status: 401 })
    return setAuthCookies(response, { accessToken: "", refreshToken: "" })
  }
}
