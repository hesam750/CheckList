import { SignJWT, jwtVerify } from "jose"
import type { AuthUser } from "@/lib/types"

const ACCESS_TOKEN_TTL = 60 * 15
const REFRESH_TOKEN_TTL = 60 * 60 * 24 * 7

export const ACCESS_COOKIE = "access_token"
export const REFRESH_COOKIE = "refresh_token"

function getJwtSecret() {
  const secret = process.env.AUTH_SECRET
  if (!secret) {
    throw new Error("AUTH_SECRET is not set")
  }
  return new TextEncoder().encode(secret)
}

export async function createAccessToken(user: AuthUser) {
  return new SignJWT({
    username: user.username,
    role: user.role,
    permissions: user.permissions,
    unit: user.unit,
    type: "access",
  })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(user.id)
    .setIssuedAt()
    .setExpirationTime(`${ACCESS_TOKEN_TTL}s`)
    .sign(getJwtSecret())
}

export async function createRefreshToken(user: AuthUser) {
  return new SignJWT({ type: "refresh" })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(user.id)
    .setIssuedAt()
    .setExpirationTime(`${REFRESH_TOKEN_TTL}s`)
    .sign(getJwtSecret())
}

export async function verifyAccessToken(token: string) {
  const { payload } = await jwtVerify(token, getJwtSecret())
  if (payload.type !== "access") {
    throw new Error("Invalid token type")
  }
  return payload
}

export async function verifyRefreshToken(token: string) {
  const { payload } = await jwtVerify(token, getJwtSecret())
  if (payload.type !== "refresh") {
    throw new Error("Invalid token type")
  }
  return payload
}

export function setAuthCookies(
  response: Response,
  tokens: { accessToken: string; refreshToken: string }
) {
  const secure = process.env.NODE_ENV === "production"
  const headers = new Headers(response.headers)
  const common = `Path=/; HttpOnly; SameSite=Lax; ${secure ? "Secure;" : ""}`
  headers.append(
    "Set-Cookie",
    `${ACCESS_COOKIE}=${tokens.accessToken}; Max-Age=${ACCESS_TOKEN_TTL}; ${common}`
  )
  headers.append(
    "Set-Cookie",
    `${REFRESH_COOKIE}=${tokens.refreshToken}; Max-Age=${REFRESH_TOKEN_TTL}; ${common}`
  )
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  })
}

export function clearAuthCookies(response: Response) {
  const secure = process.env.NODE_ENV === "production"
  const headers = new Headers(response.headers)
  const common = `Path=/; HttpOnly; SameSite=Lax; ${secure ? "Secure;" : ""}`
  headers.append("Set-Cookie", `${ACCESS_COOKIE}=; Max-Age=0; ${common}`)
  headers.append("Set-Cookie", `${REFRESH_COOKIE}=; Max-Age=0; ${common}`)
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  })
}
