const fs = require("fs")
const path = require("path")
const { Client } = require("pg")

const initPath = path.join(__dirname, "..", "db", "init.sql")
const connectionString = process.env.DATABASE_URL || process.argv[2]

if (!connectionString) {
  throw new Error("DATABASE_URL is required")
}

const sql = fs.readFileSync(initPath, "utf8")

const main = async () => {
  const client = new Client({ connectionString })
  await client.connect()
  await client.query(sql)
  const tables = ["units", "lines", "machines", "stoppages", "users", "permissions"]
  const counts = {}
  for (const table of tables) {
    const result = await client.query(`SELECT COUNT(*)::int AS count FROM ${table}`)
    counts[table] = result.rows[0]?.count ?? 0
  }
  await client.end()
  console.log(JSON.stringify({ imported: true, counts }, null, 2))
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
