import { NextResponse, type NextRequest } from "next/server"

const ACCESS_COOKIE = "access_token"

function getPermissionsFromToken(token: string) {
  try {
    const payload = token.split(".")[1]
    if (!payload) {
      return []
    }
    const normalized = payload.replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(payload.length / 4) * 4, "=")
    const data = JSON.parse(atob(normalized))
    return Array.isArray(data.permissions) ? data.permissions : []
  } catch {
    return []
  }
}

export async function middleware(request: NextRequest) {
  const token = request.cookies.get(ACCESS_COOKIE)?.value
  if (!token) {
    return NextResponse.redirect(new URL("/", request.url))
  }

  const permissions = getPermissionsFromToken(token)
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
}

export const config = {
  matcher: ["/dashboard/:path*", "/settings/:path*", "/reports/:path*", "/stoppages/:path*"],
}
