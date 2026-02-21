import { NextResponse, type NextRequest } from "next/server"
import { ACCESS_COOKIE, verifyAccessToken } from "@/lib/auth"

export async function middleware(request: NextRequest) {
  const token = request.cookies.get(ACCESS_COOKIE)?.value
  if (!token) {
    return NextResponse.redirect(new URL("/", request.url))
  }

  try {
    const payload = await verifyAccessToken(token)
    const permissions = Array.isArray(payload.permissions) ? payload.permissions : []
    const pathname = request.nextUrl.pathname
    const requiredPermission = pathname.startsWith("/dashboard")
      ? "dashboard:read"
      : pathname.startsWith("/stoppages/new")
        ? "stoppages:create"
        : pathname.startsWith("/stoppages/approve")
          ? "stoppages:approve"
          : pathname.startsWith("/reports")
            ? "reports:read"
            : pathname.startsWith("/settings")
              ? "settings:manage"
              : undefined

    if (requiredPermission && !permissions.includes(requiredPermission)) {
      const fallback = permissions.includes("stoppages:create") ? "/stoppages/new" : "/"
      return NextResponse.redirect(new URL(fallback, request.url))
    }
    return NextResponse.next()
  } catch {
    return NextResponse.redirect(new URL("/", request.url))
  }
}

export const config = {
  matcher: ["/dashboard/:path*", "/settings/:path*", "/reports/:path*", "/stoppages/:path*"],
}
