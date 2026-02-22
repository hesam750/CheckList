export type UserRole = "operator" | "supervisor" | "inspector" | "admin"
export type Permission =
  | "dashboard:read"
  | "stoppages:create"
  | "stoppages:approve"
  | "reports:read"
  | "settings:manage"
  | "users:manage"

export interface User {
  id: string
  name: string
  username: string
  role: UserRole
  unit: string
}

export interface AuthUser extends User {
  permissions: Permission[]
}

export type StoppageStatus = "pending_supervisor" | "pending_inspector" | "approved" | "rejected"

export interface Stoppage {
  id: string
  code?: string
  unit: string
  line: string
  machine: string
  shift: string
  startDate?: string
  startClock?: string
  startTime: string
  endDate?: string
  endClock?: string
  endTime: string
  durationMinutes?: number
  type: string
  cause: string
  description: string
  status: StoppageStatus
  createdBy: string
  createdAt: string
  supervisorApproval?: { by: string; at: string; note?: string }
  inspectorApproval?: { by: string; at: string; note?: string }
}

export interface Unit {
  id: string
  name: string
  lines: Line[]
}

export interface Line {
  id: string
  name: string
  unitId: string
  machines: Machine[]
}

export interface Machine {
  id: string
  name: string
  lineId: string
  mtbfTarget: number
  mttrTarget: number
}

export interface KPIData {
  mtbf: number
  mttr: number
  availability: number
  totalStoppages: number
  totalDowntime: number
  mtbfTarget: number
  mttrTarget: number
}
