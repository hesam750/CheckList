"use client"

import { useEffect, useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { Checkbox } from "@/components/ui/checkbox"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { units } from "@/lib/mock-data"
import type { AuthUser, Permission, UserRole } from "@/lib/types"
import { Plus, Pencil, Trash2, Building2, GitBranch, Cog, Users, KeyRound } from "lucide-react"

const roleLabels: Record<string, string> = {
  operator: "اپراتور",
  supervisor: "سرپرست",
  inspector: "ناظر",
  admin: "مدیر سیستم",
}

const permissionOptions: { id: Permission; label: string; description: string }[] = [
  { id: "dashboard:read", label: "مشاهده داشبورد", description: "دسترسی به شاخص‌ها و خلاصه عملکرد" },
  { id: "stoppages:create", label: "ثبت توقفات", description: "ثبت توقف جدید برای خطوط تولید" },
  { id: "stoppages:approve", label: "تایید توقفات", description: "بررسی و تایید توقف‌های ثبت‌شده" },
  { id: "reports:read", label: "مشاهده گزارش‌ها", description: "دسترسی به گزارش علت توقف و تحلیل‌ها" },
  { id: "settings:manage", label: "مدیریت پایه", description: "مدیریت واحدها، ماشین‌آلات و ساختارها" },
  { id: "users:manage", label: "مدیریت کاربران", description: "ایجاد و مدیریت کاربران سامانه" },
]

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState("units")
  const [addDialogOpen, setAddDialogOpen] = useState(false)
  const [addType, setAddType] = useState("")
  const [users, setUsers] = useState<AuthUser[]>([])
  const [usersLoading, setUsersLoading] = useState(true)
  const [permissionDialogOpen, setPermissionDialogOpen] = useState(false)
  const [permissionUser, setPermissionUser] = useState<AuthUser | null>(null)
  const [selectedPermissions, setSelectedPermissions] = useState<Permission[]>([])
  const [permissionSaving, setPermissionSaving] = useState(false)
  const [newUserName, setNewUserName] = useState("")
  const [newUsername, setNewUsername] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [newRole, setNewRole] = useState<UserRole | "">("")
  const [newUnit, setNewUnit] = useState("")
  const [addSaving, setAddSaving] = useState(false)
  const [addError, setAddError] = useState("")

  const openAdd = (type: string) => {
    setAddType(type)
    setAddDialogOpen(true)
    if (type === "user") {
      setNewUserName("")
      setNewUsername("")
      setNewPassword("")
      setNewRole("")
      setNewUnit("")
      setAddError("")
    }
  }

  useEffect(() => {
    fetch("/api/users")
      .then((res) => (res.ok ? res.json() : []))
      .then((data) => setUsers(Array.isArray(data) ? data : []))
      .finally(() => setUsersLoading(false))
  }, [])

  const openPermissions = (user: AuthUser) => {
    setPermissionUser(user)
    setSelectedPermissions(user.permissions ?? [])
    setPermissionDialogOpen(true)
  }

  const togglePermission = (permission: Permission, checked: boolean) => {
    setSelectedPermissions((prev) => {
      if (checked) return prev.includes(permission) ? prev : [...prev, permission]
      return prev.filter((item) => item !== permission)
    })
  }

  const savePermissions = () => {
    if (!permissionUser) return
    setPermissionSaving(true)
    fetch("/api/users", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id: permissionUser.id, permissions: selectedPermissions }),
    })
      .then((res) => {
        if (!res.ok) {
          throw new Error()
        }
        setUsers((prev) =>
          prev.map((user) =>
            user.id === permissionUser.id ? { ...user, permissions: selectedPermissions } : user
          )
        )
        setPermissionDialogOpen(false)
      })
      .finally(() => setPermissionSaving(false))
  }

  const saveAddDialog = () => {
    if (addType !== "user") {
      setAddDialogOpen(false)
      return
    }
    if (!newUserName || !newUsername || !newPassword || !newRole || !newUnit) {
      setAddError("همه فیلدها را کامل کنید")
      return
    }
    const unitLabel =
      newUnit === "all" ? "همه واحدها" : units.find((item) => item.id === newUnit)?.name ?? ""
    if (!unitLabel) {
      setAddError("واحد را انتخاب کنید")
      return
    }
    setAddSaving(true)
    setAddError("")
    fetch("/api/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: newUserName,
        username: newUsername,
        password: newPassword,
        role: newRole,
        unit: unitLabel,
      }),
    })
      .then(async (res) => {
        const data = await res.json().catch(() => null)
        if (!res.ok) {
          setAddError(data?.message ?? "خطا در ذخیره کاربر")
          return
        }
        if (data?.user) {
          setUsers((prev) => [data.user, ...prev])
        }
        setAddDialogOpen(false)
      })
      .finally(() => setAddSaving(false))
  }

  return (
    <AppLayout>
      <div className="p-4 sm:p-6 space-y-6 text-right" dir="rtl">
        <div>
          <h1 className="text-2xl font-bold text-foreground">مدیریت پایه</h1>
          <p className="text-sm text-muted-foreground mt-1">تعریف واحدها، خطوط، ماشین‌ها، اهداف و کاربران</p>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="bg-secondary border border-border flex flex-row-reverse flex-wrap justify-start gap-2 w-full">
            <TabsTrigger value="units" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-2 w-full sm:w-auto justify-center">
              <Building2 className="h-4 w-4" />
              واحدها و خطوط
            </TabsTrigger>
            <TabsTrigger value="machines" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-2 w-full sm:w-auto justify-center">
              <Cog className="h-4 w-4" />
              ماشین‌آلات
            </TabsTrigger>
            <TabsTrigger value="targets" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-2 w-full sm:w-auto justify-center">
              <GitBranch className="h-4 w-4" />
              اهداف KPI
            </TabsTrigger>
            <TabsTrigger value="users" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-2 w-full sm:w-auto justify-center">
              <Users className="h-4 w-4" />
              کاربران
            </TabsTrigger>
          </TabsList>

          {/* Units & Lines Tab */}
          <TabsContent value="units" className="mt-6">
            <Card className="bg-card border-border">
              <CardHeader className="flex flex-col gap-3 pb-3 sm:flex-row-reverse sm:items-center sm:justify-between">
                <CardTitle className="text-base font-semibold text-card-foreground">واحدها و خطوط تولید</CardTitle>
                <Button size="sm" onClick={() => openAdd("unit")} className="bg-primary text-primary-foreground hover:bg-primary/90 w-full sm:w-auto">
                  <Plus className="h-4 w-4" />
                  افزودن واحد
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {units.map((unit) => (
                    <div key={unit.id} className="rounded-lg border border-border p-4">
                      <div className="flex flex-col gap-3 sm:flex-row-reverse sm:items-center sm:justify-between mb-3">
                        <div className="flex items-center gap-2 sm:flex-row-reverse">
                          <Building2 className="h-4 w-4 text-primary" />
                          <h3 className="font-semibold text-card-foreground">{unit.name}</h3>
                          <Badge variant="secondary" className="text-xs">{unit.lines.length} خط</Badge>
                        </div>
                        <div className="flex items-center gap-1">
                          <Button size="sm" variant="ghost" className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground hover:bg-secondary">
                            <Pencil className="h-3.5 w-3.5" />
                            <span className="sr-only">ویرایش</span>
                          </Button>
                          <Button size="sm" variant="ghost" className="h-8 w-8 p-0 text-muted-foreground hover:text-destructive hover:bg-destructive/10">
                            <Trash2 className="h-3.5 w-3.5" />
                            <span className="sr-only">حذف</span>
                          </Button>
                        </div>
                      </div>
                      <div className="grid grid-cols-1 gap-2 sm:grid-cols-2 lg:grid-cols-3">
                        {unit.lines.map((line) => (
                          <div key={line.id} className="flex flex-col gap-2 sm:flex-row-reverse sm:items-center sm:justify-between rounded-md bg-secondary px-3 py-2">
                            <div>
                              <p className="text-sm text-secondary-foreground">{line.name}</p>
                              <p className="text-xs text-muted-foreground">{line.machines.length} ماشین</p>
                            </div>
                            <div className="flex items-center gap-1">
                              <Button size="sm" variant="ghost" className="h-7 w-7 p-0 text-muted-foreground hover:text-foreground">
                                <Pencil className="h-3 w-3" />
                                <span className="sr-only">ویرایش</span>
                              </Button>
                            </div>
                          </div>
                        ))}
                        <button
                          onClick={() => openAdd("line")}
                          className="flex items-center justify-center gap-1 rounded-md border border-dashed border-border px-3 py-2 text-sm text-muted-foreground hover:text-foreground hover:border-primary transition-colors"
                        >
                          <Plus className="h-3.5 w-3.5" />
                          افزودن خط
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Machines Tab */}
          <TabsContent value="machines" className="mt-6">
            <Card className="bg-card border-border">
              <CardHeader className="flex flex-col gap-3 pb-3 sm:flex-row-reverse sm:items-center sm:justify-between">
                <CardTitle className="text-base font-semibold text-card-foreground">لیست ماشین‌آلات</CardTitle>
                <Button size="sm" onClick={() => openAdd("machine")} className="bg-primary text-primary-foreground hover:bg-primary/90 w-full sm:w-auto">
                  <Plus className="h-4 w-4" />
                  افزودن ماشین
                </Button>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow className="border-border hover:bg-transparent">
                        <TableHead className="text-right text-muted-foreground">نام ماشین</TableHead>
                        <TableHead className="text-right text-muted-foreground">واحد</TableHead>
                        <TableHead className="text-right text-muted-foreground">خط</TableHead>
                        <TableHead className="text-right text-muted-foreground">{'هدف MTBF (دقیقه)'}</TableHead>
                        <TableHead className="text-right text-muted-foreground">{'هدف MTTR (دقیقه)'}</TableHead>
                        <TableHead className="text-right text-muted-foreground">عملیات</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {units.flatMap((unit) =>
                        unit.lines.flatMap((line) =>
                          line.machines.map((machine) => (
                            <TableRow key={machine.id} className="border-border">
                              <TableCell className="text-card-foreground text-sm font-medium">{machine.name}</TableCell>
                              <TableCell className="text-card-foreground text-sm">{unit.name}</TableCell>
                              <TableCell className="text-card-foreground text-sm">{line.name}</TableCell>
                              <TableCell className="text-card-foreground text-sm">{machine.mtbfTarget}</TableCell>
                              <TableCell className="text-card-foreground text-sm">{machine.mttrTarget}</TableCell>
                              <TableCell>
                                <div className="flex items-center justify-end gap-1">
                                  <Button size="sm" variant="ghost" className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground hover:bg-secondary">
                                    <Pencil className="h-3.5 w-3.5" />
                                    <span className="sr-only">ویرایش</span>
                                  </Button>
                                  <Button size="sm" variant="ghost" className="h-8 w-8 p-0 text-muted-foreground hover:text-destructive hover:bg-destructive/10">
                                    <Trash2 className="h-3.5 w-3.5" />
                                    <span className="sr-only">حذف</span>
                                  </Button>
                                </div>
                              </TableCell>
                            </TableRow>
                          ))
                        )
                      )}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* KPI Targets Tab */}
          <TabsContent value="targets" className="mt-6">
            <Card className="bg-card border-border">
              <CardHeader className="pb-3">
                <CardTitle className="text-base font-semibold text-card-foreground">{'اهداف MTBF / MTTR'}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {units.flatMap((unit) =>
                    unit.lines.flatMap((line) =>
                      line.machines.map((machine) => (
                        <div key={machine.id} className="rounded-lg border border-border p-4 space-y-3">
                          <div>
                            <p className="text-sm font-medium text-card-foreground">{machine.name}</p>
                            <p className="text-xs text-muted-foreground">{unit.name} / {line.name}</p>
                          </div>
                          <div className="grid grid-cols-2 gap-3">
                            <div className="space-y-1.5">
                              <Label className="text-xs text-muted-foreground">{'هدف MTBF (دقیقه)'}</Label>
                              <Input
                                type="number"
                                defaultValue={machine.mtbfTarget}
                                className="h-9 bg-secondary text-secondary-foreground text-sm"
                                dir="ltr"
                              />
                            </div>
                            <div className="space-y-1.5">
                              <Label className="text-xs text-muted-foreground">{'هدف MTTR (دقیقه)'}</Label>
                              <Input
                                type="number"
                                defaultValue={machine.mttrTarget}
                                className="h-9 bg-secondary text-secondary-foreground text-sm"
                                dir="ltr"
                              />
                            </div>
                          </div>
                          <Button size="sm" variant="outline" className="w-full border-border text-foreground hover:bg-secondary text-xs">
                            ذخیره تغییرات
                          </Button>
                        </div>
                      ))
                    )
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Users Tab */}
          <TabsContent value="users" className="mt-6">
            <Card className="bg-card border-border">
              <CardHeader className="flex flex-col gap-3 pb-3 sm:flex-row-reverse sm:items-center sm:justify-between">
                <CardTitle className="text-base font-semibold text-card-foreground">کاربران و نقش‌ها</CardTitle>
                <Button size="sm" onClick={() => openAdd("user")} className="bg-primary text-primary-foreground hover:bg-primary/90 w-full sm:w-auto">
                  <Plus className="h-4 w-4" />
                  افزودن کاربر
                </Button>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow className="border-border hover:bg-transparent">
                        <TableHead className="text-right text-muted-foreground">نام</TableHead>
                        <TableHead className="text-right text-muted-foreground">نام کاربری</TableHead>
                        <TableHead className="text-right text-muted-foreground">نقش</TableHead>
                        <TableHead className="text-right text-muted-foreground">واحد</TableHead>
                        <TableHead className="text-right text-muted-foreground">دسترسی‌ها</TableHead>
                        <TableHead className="text-right text-muted-foreground">عملیات</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {usersLoading ? (
                        <TableRow className="border-border">
                          <TableCell colSpan={6} className="text-center text-sm text-muted-foreground">
                            در حال دریافت کاربران...
                          </TableCell>
                        </TableRow>
                      ) : (
                        users.map((user) => (
                          <TableRow key={user.id} className="border-border">
                            <TableCell className="text-card-foreground text-sm font-medium">{user.name}</TableCell>
                            <TableCell className="text-muted-foreground text-sm font-mono" dir="ltr">{user.username}</TableCell>
                            <TableCell>
                              <Badge variant="secondary" className="text-xs">
                                {roleLabels[user.role]}
                              </Badge>
                            </TableCell>
                            <TableCell className="text-card-foreground text-sm">{user.unit}</TableCell>
                            <TableCell>
                              <Badge variant="outline" className="text-xs border-border">
                                {user.permissions?.length ?? 0} دسترسی
                              </Badge>
                            </TableCell>
                              <TableCell>
                                <div className="flex items-center justify-end gap-1">
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground hover:bg-secondary"
                                  onClick={() => openPermissions(user)}
                                >
                                  <KeyRound className="h-3.5 w-3.5" />
                                  <span className="sr-only">مدیریت دسترسی‌ها</span>
                                </Button>
                                <Button size="sm" variant="ghost" className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground hover:bg-secondary">
                                  <Pencil className="h-3.5 w-3.5" />
                                  <span className="sr-only">ویرایش</span>
                                </Button>
                                <Button size="sm" variant="ghost" className="h-8 w-8 p-0 text-muted-foreground hover:text-destructive hover:bg-destructive/10">
                                  <Trash2 className="h-3.5 w-3.5" />
                                  <span className="sr-only">حذف</span>
                                </Button>
                              </div>
                            </TableCell>
                          </TableRow>
                        ))
                      )}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* Add Dialog */}
        <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
          <DialogContent className="w-full max-w-md bg-card text-card-foreground border-border text-right">
            <DialogHeader>
              <DialogTitle className="text-card-foreground">
                {addType === "unit" && "افزودن واحد جدید"}
                {addType === "line" && "افزودن خط تولید"}
                {addType === "machine" && "افزودن ماشین"}
                {addType === "user" && "افزودن کاربر جدید"}
              </DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              {addType === "unit" && (
                <div className="space-y-2">
                  <Label className="text-card-foreground">نام واحد</Label>
                  <Input placeholder="مثال: واحد تولید ۴" className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground" />
                </div>
              )}
              {addType === "line" && (
                <>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">واحد</Label>
                    <Select>
                      <SelectTrigger className="bg-secondary text-secondary-foreground">
                        <SelectValue placeholder="واحد را انتخاب کنید" />
                      </SelectTrigger>
                      <SelectContent>
                        {units.map((u) => (
                          <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">نام خط تولید</Label>
                    <Input placeholder="مثال: خط تولید F" className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground" />
                  </div>
                </>
              )}
              {addType === "machine" && (
                <>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">نام ماشین</Label>
                    <Input placeholder="مثال: دستگاه پرس ۳" className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground" />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-2">
                      <Label className="text-card-foreground">{'هدف MTBF (دقیقه)'}</Label>
                      <Input type="number" placeholder="120" className="bg-secondary text-secondary-foreground" dir="ltr" />
                    </div>
                    <div className="space-y-2">
                      <Label className="text-card-foreground">{'هدف MTTR (دقیقه)'}</Label>
                      <Input type="number" placeholder="30" className="bg-secondary text-secondary-foreground" dir="ltr" />
                    </div>
                  </div>
                </>
              )}
              {addType === "user" && (
                <>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">نام و نام خانوادگی</Label>
                    <Input
                      placeholder="مثال: علی رضایی"
                      className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground"
                      value={newUserName}
                      onChange={(event) => setNewUserName(event.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">نام کاربری</Label>
                    <Input
                      placeholder="مثال: a.rezaei"
                      className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground"
                      dir="ltr"
                      value={newUsername}
                      onChange={(event) => setNewUsername(event.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">رمز عبور</Label>
                    <Input
                      type="password"
                      placeholder="رمز عبور را وارد کنید"
                      className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground"
                      dir="ltr"
                      value={newPassword}
                      onChange={(event) => setNewPassword(event.target.value)}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">نقش</Label>
                    <Select value={newRole} onValueChange={(value) => setNewRole(value as UserRole)}>
                      <SelectTrigger className="bg-secondary text-secondary-foreground">
                        <SelectValue placeholder="نقش را انتخاب کنید" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="operator">اپراتور</SelectItem>
                        <SelectItem value="supervisor">سرپرست</SelectItem>
                        <SelectItem value="inspector">ناظر</SelectItem>
                        <SelectItem value="admin">مدیر سیستم</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-card-foreground">واحد</Label>
                    <Select value={newUnit} onValueChange={setNewUnit}>
                      <SelectTrigger className="bg-secondary text-secondary-foreground">
                        <SelectValue placeholder="واحد را انتخاب کنید" />
                      </SelectTrigger>
                      <SelectContent>
                        {units.map((u) => (
                          <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
                        ))}
                        <SelectItem value="all">همه واحدها</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  {addError ? <p className="text-xs text-destructive">{addError}</p> : null}
                </>
              )}
            </div>
            <DialogFooter className="gap-2">
              <Button variant="outline" onClick={() => setAddDialogOpen(false)} className="border-border text-foreground">
                انصراف
              </Button>
              <Button
                onClick={saveAddDialog}
                className="bg-primary text-primary-foreground hover:bg-primary/90"
                disabled={addSaving}
              >
                {addSaving ? "در حال ذخیره..." : "ذخیره"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        <Dialog open={permissionDialogOpen} onOpenChange={setPermissionDialogOpen}>
          <DialogContent className="w-full max-w-lg bg-card text-card-foreground border-border text-right">
            <DialogHeader>
              <DialogTitle className="text-card-foreground">مدیریت دسترسی‌ها</DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              <div className="rounded-lg border border-border p-3 bg-secondary/40">
                <p className="text-sm font-medium text-card-foreground">{permissionUser?.name ?? "—"}</p>
                <p className="text-xs text-muted-foreground">{permissionUser ? roleLabels[permissionUser.role] : "—"}</p>
              </div>
              <div className="grid grid-cols-1 gap-3">
                {permissionOptions.map((permission) => (
                  <div key={permission.id} className="flex flex-row-reverse items-center justify-between rounded-lg border border-border p-3">
                    <div>
                      <p className="text-sm text-card-foreground">{permission.label}</p>
                      <p className="text-xs text-muted-foreground">{permission.description}</p>
                    </div>
                    <Checkbox
                      checked={selectedPermissions.includes(permission.id)}
                      onCheckedChange={(checked) => togglePermission(permission.id, Boolean(checked))}
                    />
                  </div>
                ))}
              </div>
            </div>
            <DialogFooter className="gap-2">
              <Button variant="outline" onClick={() => setPermissionDialogOpen(false)} className="border-border text-foreground">
                انصراف
              </Button>
              <Button
                onClick={savePermissions}
                className="bg-primary text-primary-foreground hover:bg-primary/90"
                disabled={permissionSaving}
              >
                {permissionSaving ? "در حال ذخیره..." : "ذخیره دسترسی‌ها"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AppLayout>
  )
}
