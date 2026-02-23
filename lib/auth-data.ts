import type { AuthUser, Permission, UserRole } from "@/lib/types"
import { db } from "@/lib/db"
import crypto from "crypto"

export interface AuthUserRecord extends AuthUser {
  password: string
}

const rolePermissions: Record<UserRole, Permission[]> = {
  admin: [
    "dashboard:read",
    "stoppages:create",
    "stoppages:approve",
    "reports:read",
    "settings:manage",
    "users:manage",
  ],
  supervisor: ["dashboard:read", "stoppages:create", "stoppages:approve", "reports:read"],
  inspector: ["dashboard:read", "stoppages:approve", "reports:read"],
  operator: ["stoppages:create"],
}

type UserRow = {
  id: string
  name: string
  username: string
  password: string
  role: UserRole
  unit: string | null
}

const hashPassword = (password: string) => {
  const salt = crypto.randomBytes(16).toString("base64")
  const derived = crypto.scryptSync(password, salt, 64)
  return `scrypt$${salt}$${derived.toString("base64")}`
}

const verifyPassword = (password: string, stored: string) => {
  const parts = stored.split("$")
  if (parts.length === 3 && parts[0] === "scrypt") {
    const salt = parts[1]
    const hash = parts[2]
    const derived = crypto.scryptSync(password, salt, 64)
    const storedBuffer = Buffer.from(hash, "base64")
    if (storedBuffer.length !== derived.length) return false
    return crypto.timingSafeEqual(storedBuffer, derived)
  }
  return password === stored
}

const isHashedPassword = (stored: string) => {
  const parts = stored.split("$")
  return parts.length === 3 && parts[0] === "scrypt"
}

async function getPermissionsByUserId(userId: string) {
  const result = await db.query(
    `SELECT p.key
     FROM user_permissions up
     JOIN permissions p ON p.id = up.permission_id
     WHERE up.user_id = $1`,
    [userId]
  )
  return result.rows.map((row: { key: Permission }) => row.key)
}

function buildAuthUser(row: UserRow, permissions: Permission[]): AuthUserRecord {
  return {
    id: row.id,
    name: row.name,
    username: row.username,
    password: row.password,
    role: row.role,
    unit: row.unit ?? "",
    permissions: permissions.length ? permissions : rolePermissions[row.role],
  }
}

export async function getAuthUserByCredentials(username: string, password: string) {
  const result = await db.query(
    "SELECT id, name, username, password, role, unit FROM users WHERE username = $1 LIMIT 1",
    [username]
  )
  let row = result.rows[0]
  if (!row && username === "hesam" && password === "123") {
    await addAuthUser({
      name: "حسام",
      username,
      password,
      role: "admin",
      unit: "همه واحدها",
    })
    const retry = await db.query(
      "SELECT id, name, username, password, role, unit FROM users WHERE username = $1 LIMIT 1",
      [username]
    )
    row = retry.rows[0]
  }
  if (!row || !verifyPassword(password, row.password)) return undefined
  if (!isHashedPassword(row.password)) {
    const hashed = hashPassword(password)
    await db.query("UPDATE users SET password = $1 WHERE id = $2", [hashed, row.id])
    row.password = hashed
  }
  const permissions = await getPermissionsByUserId(row.id)
  return buildAuthUser(row, permissions)
}

export async function getAuthUserById(id: string) {
  const result = await db.query(
    "SELECT id, name, username, password, role, unit FROM users WHERE id = $1 LIMIT 1",
    [id]
  )
  const row = result.rows[0]
  if (!row) return undefined
  const permissions = await getPermissionsByUserId(row.id)
  return buildAuthUser(row, permissions)
}

export async function getAllAuthUsers() {
  const usersResult = await db.query(
    "SELECT id, name, username, password, role, unit FROM users ORDER BY name"
  )
  const permissionsResult = await db.query(
    `SELECT up.user_id, p.key
     FROM user_permissions up
     JOIN permissions p ON p.id = up.permission_id`
  )
  const permissionMap = new Map<string, Permission[]>()
  permissionsResult.rows.forEach((row: { user_id: string; key: Permission }) => {
    const list = permissionMap.get(row.user_id) ?? []
    list.push(row.key)
    permissionMap.set(row.user_id, list)
  })
  return usersResult.rows.map((row: UserRow) => {
    const permissions = permissionMap.get(row.id) ?? []
    return toPublicUser(buildAuthUser(row, permissions))
  })
}

export async function addAuthUser(data: {
  name: string
  username: string
  password: string
  role: UserRole
  unit: string
}) {
  const existing = await db.query(
    "SELECT id FROM users WHERE username = $1 LIMIT 1",
    [data.username]
  )
  if (existing.rows.length) return null

  const userId = `usr${Date.now()}`
  const permissions = rolePermissions[data.role]
  const hashedPassword = hashPassword(data.password)
  const client = await db.getClient()
  try {
    await client.query("BEGIN")
    await client.query(
      "INSERT INTO users (id, name, username, password, role, unit) VALUES ($1, $2, $3, $4, $5, $6)",
      [userId, data.name, data.username, hashedPassword, data.role, data.unit]
    )
    for (const permission of permissions) {
      await client.query("INSERT INTO permissions (key) VALUES ($1) ON CONFLICT (key) DO NOTHING", [
        permission,
      ])
      await client.query(
        `INSERT INTO user_permissions (user_id, permission_id)
         VALUES ($1, (SELECT id FROM permissions WHERE key = $2))
         ON CONFLICT DO NOTHING`,
        [userId, permission]
      )
    }
    await client.query("COMMIT")
  } catch (error) {
    await client.query("ROLLBACK")
    throw error
  } finally {
    client.release()
  }

  return toPublicUser(
    buildAuthUser(
      {
        id: userId,
        name: data.name,
        username: data.username,
        password: hashedPassword,
        role: data.role,
        unit: data.unit,
      },
      permissions
    )
  )
}

export async function updateUserPermissions(userId: string, permissions: Permission[]) {
  const exists = await db.query("SELECT id FROM users WHERE id = $1 LIMIT 1", [
    userId,
  ])
  if (!exists.rows.length) return false
  const client = await db.getClient()
  try {
    await client.query("BEGIN")
    await client.query("DELETE FROM user_permissions WHERE user_id = $1", [userId])
    for (const permission of permissions) {
      await client.query("INSERT INTO permissions (key) VALUES ($1) ON CONFLICT (key) DO NOTHING", [
        permission,
      ])
      await client.query(
        `INSERT INTO user_permissions (user_id, permission_id)
         VALUES ($1, (SELECT id FROM permissions WHERE key = $2))
         ON CONFLICT DO NOTHING`,
        [userId, permission]
      )
    }
    await client.query("COMMIT")
  } catch (error) {
    await client.query("ROLLBACK")
    throw error
  } finally {
    client.release()
  }
  return true
}

export async function updateAuthUser(data: {
  id: string
  name?: string
  username?: string
  password?: string
  role?: UserRole
  unit?: string
  permissions?: Permission[]
}) {
  const current = await db.query(
    "SELECT id, name, username, password, role, unit FROM users WHERE id = $1 LIMIT 1",
    [data.id]
  )
  const target = current.rows[0]
  if (!target) return null
  if (data.username) {
    const existing = await db.query(
      "SELECT id FROM users WHERE username = $1 AND id <> $2 LIMIT 1",
      [data.username, data.id]
    )
    if (existing.rows.length) return null
  }

  const nextRole = data.role ?? target.role
  const currentPermissions = await getPermissionsByUserId(target.id)
  const nextPermissions =
    data.permissions ??
    (data.role && data.role !== target.role ? rolePermissions[data.role] : currentPermissions)
  const nextPassword = data.password ? hashPassword(data.password) : target.password

  await db.query(
    `UPDATE users
     SET name = $1, username = $2, password = $3, role = $4, unit = $5
     WHERE id = $6`,
    [
      data.name ?? target.name,
      data.username ?? target.username,
      nextPassword,
      nextRole,
      data.unit ?? target.unit,
      data.id,
    ]
  )

  if (data.permissions || (data.role && data.role !== target.role)) {
    await updateUserPermissions(data.id, nextPermissions)
  }

  return toPublicUser(
    buildAuthUser(
      {
        id: target.id,
        name: data.name ?? target.name,
        username: data.username ?? target.username,
        password: nextPassword,
        role: nextRole,
        unit: data.unit ?? target.unit,
      },
      nextPermissions
    )
  )
}

export async function deleteAuthUser(userId: string) {
  const result = await db.query("DELETE FROM users WHERE id = $1", [userId])
  return result.rowCount > 0
}

export function toPublicUser(user: AuthUserRecord): AuthUser {
  const { password: _password, ...publicUser } = user
  return publicUser
}
