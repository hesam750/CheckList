import { NextResponse } from "next/server"
import { ACCESS_COOKIE, verifyAccessToken } from "@/lib/auth"
import { getAuthUserById, toPublicUser } from "@/lib/auth-data"

export async function GET(request: Request) {
  const cookies = request.headers.get("cookie") ?? ""
  const accessToken = cookies
    .split(";")
    .map((item) => item.trim())
    .find((item) => item.startsWith(`${ACCESS_COOKIE}=`))
    ?.split("=")[1]

  if (!accessToken) {
    return NextResponse.json({ message: "ورود انجام نشده است" }, { status: 401 })
  }

  try {
    const payload = await verifyAccessToken(accessToken)
    const userId = payload.sub as string | undefined
    const user = userId ? await getAuthUserById(userId) : undefined
    if (!user) {
      return NextResponse.json({ message: "ورود انجام نشده است" }, { status: 401 })
    }
    return NextResponse.json({ user: toPublicUser(user) })
  } catch {
    return NextResponse.json({ message: "ورود انجام نشده است" }, { status: 401 })
  }
}
