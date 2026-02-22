const { Client } = require("pg")
const crypto = require("crypto")

const connectionString = process.env.DATABASE_URL || process.argv[2]

if (!connectionString) {
  throw new Error("DATABASE_URL is required")
}

const user = {
  name: "حسام",
  username: "hesam",
  password: "123",
  role: "admin",
  unit: "همه واحدها",
}

const permissionKeys = [
  "dashboard:read",
  "stoppages:create",
  "stoppages:approve",
  "reports:read",
  "settings:manage",
  "users:manage",
]

const hashPassword = (password) => {
  const salt = crypto.randomBytes(16).toString("base64")
  const derived = crypto.scryptSync(String(password), salt, 64)
  return `scrypt$${salt}$${derived.toString("base64")}`
}

const isHashed = (value) => typeof value === "string" && value.startsWith("scrypt$")

const main = async () => {
  const client = new Client({ connectionString })
  await client.connect()
  try {
    await client.query("BEGIN")
    const values = permissionKeys
      .map((_, index) => `($${index + 1})`)
      .join(", ")
    await client.query(
      `INSERT INTO permissions (key) VALUES ${values} ON CONFLICT (key) DO NOTHING`,
      permissionKeys
    )

    const existing = await client.query("SELECT id FROM users WHERE username = $1", [
      user.username,
    ])
    const userId = existing.rows[0]?.id ?? `usr${Date.now()}`

    const hashedPassword = hashPassword(user.password)

    if (existing.rows.length) {
      await client.query(
        "UPDATE users SET name = $1, password = $2, role = $3, unit = $4 WHERE id = $5",
        [user.name, hashedPassword, user.role, user.unit, userId]
      )
    } else {
      await client.query(
        "INSERT INTO users (id, name, username, password, role, unit) VALUES ($1, $2, $3, $4, $5, $6)",
        [userId, user.name, user.username, hashedPassword, user.role, user.unit]
      )
    }

    if (process.env.REHASH_ALL === "1") {
      const allUsers = await client.query("SELECT id, password FROM users")
      for (const row of allUsers.rows) {
        if (isHashed(row.password)) continue
        const nextHash = hashPassword(row.password ?? "")
        await client.query("UPDATE users SET password = $1 WHERE id = $2", [
          nextHash,
          row.id,
        ])
      }
    }

    await client.query("DELETE FROM user_permissions WHERE user_id = $1", [userId])

    const permissions = await client.query("SELECT id FROM permissions")
    for (const row of permissions.rows) {
      await client.query(
        "INSERT INTO user_permissions (user_id, permission_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
        [userId, row.id]
      )
    }

    await client.query("COMMIT")

    const summary = await client.query(
      "SELECT id, name, username, role, unit FROM users WHERE id = $1",
      [userId]
    )
    const countResult = await client.query(
      "SELECT COUNT(*)::int AS count FROM user_permissions WHERE user_id = $1",
      [userId]
    )
    console.log(
      JSON.stringify(
        {
          user: summary.rows[0],
          permissions: countResult.rows[0]?.count ?? 0,
        },
        null,
        2
      )
    )
  } catch (error) {
    await client.query("ROLLBACK")
    throw error
  } finally {
    await client.end()
  }
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
