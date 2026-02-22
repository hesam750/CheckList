"use client"

import Link from "next/link"
import Image from "next/image"
import { usePathname } from "next/navigation"
import { useEffect, useState } from "react"
import { useTheme } from "next-themes"
import {
  LayoutDashboard,
  AlertTriangle,
  CheckSquare,
  BarChart3,
  Settings,
  LogOut,
  Moon,
  Sun,
  Menu,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { Sheet, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Button } from "@/components/ui/button"
import type { AuthUser, Permission } from "@/lib/types"

const navItems = [
  { href: "/dashboard", label: "داشبورد", icon: LayoutDashboard, permission: "dashboard:read" },
  { href: "/stoppages/new", label: "ثبت توقف", icon: AlertTriangle, permission: "stoppages:create" },
  { href: "/stoppages/approve", label: "تایید توقف‌ها", icon: CheckSquare, permission: "stoppages:approve" },
  { href: "/reports", label: "گزارش علت توقف", icon: BarChart3, permission: "reports:read" },
  { href: "/settings", label: "مدیریت پایه", icon: Settings, permission: "settings:manage" },
]

const roleLabels: Record<string, string> = {
  operator: "اپراتور",
  supervisor: "سرپرست",
  inspector: "ناظر",
  admin: "مدیر سیستم",
}

function SidebarContent({
  pathname,
  user,
  ready,
}: {
  pathname: string | null
  user: AuthUser | null
  ready: boolean
}) {
  const permissions = user?.permissions ?? []
  const allowedItems = ready
    ? navItems.filter((item) => permissions.includes(item.permission as Permission))
    : []

  return (
    <>
      <div className="flex items-center gap-3 px-6 py-5 border-b border-sidebar-border">
        <div className="flex h-28 w-28 items-center justify-center">
          <Image src="/fanap.png" alt="لوگو فناپ" width={96} height={96} className="h-24 w-24 object-contain" />
        </div>
        <div>
          <h1 className="text-sm font-bold text-sidebar-foreground">سامانه توقفات</h1>
          <p className="text-xs text-sidebar-foreground/60">مدیریت خطوط تولید</p>
        </div>
      </div>

      <nav className="flex-1 px-3 py-4 space-y-1">
        {allowedItems.map((item) => {
          const isActive = pathname === item.href || pathname?.startsWith(item.href + "/")
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors",
                isActive
                  ? "bg-sidebar-primary text-sidebar-primary-foreground"
                  : "text-sidebar-foreground/70 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
              )}
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </Link>
          )
        })}
      </nav>

      <div className="border-t border-sidebar-border p-3">
        <div className="flex items-center gap-3 rounded-lg px-3 py-2.5 mb-1">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-sidebar-accent text-sidebar-accent-foreground text-xs font-bold">
            {user?.name ? user.name.split(" ").map((part) => part[0]).slice(0, 2).join("‌") : "—"}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-sidebar-foreground truncate">{user?.name ?? "—"}</p>
            <p className="text-xs text-sidebar-foreground/50">{user ? roleLabels[user.role] : "—"}</p>
          </div>
        </div>
        <Link
          href="/"
          className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-sidebar-foreground/60 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground transition-colors"
        >
          <LogOut className="h-4 w-4" />
          خروج
        </Link>
      </div>
    </>
  )
}

export function AppSidebar({ user, ready }: { user: AuthUser | null; ready: boolean }) {
  const pathname = usePathname()

  return (
    <aside className="fixed right-0 top-0 z-40 hidden h-screen w-64 flex-col bg-sidebar text-sidebar-foreground border-l border-sidebar-border lg:flex">
      <SidebarContent
        pathname={pathname}
        user={user}
        ready={ready}
      />
    </aside>
  )
}

export function AppLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const { theme, setTheme } = useTheme()
  const [user, setUser] = useState<AuthUser | null>(null)
  const [userReady, setUserReady] = useState(false)

  useEffect(() => {
    fetch("/api/auth/me")
      .then((res) => (res.ok ? res.json() : null))
      .then((data) => setUser(data?.user ?? null))
      .finally(() => setUserReady(true))
  }, [])

  const isDark = theme === "dark"

  return (
    <div className="min-h-screen bg-background">
      <AppSidebar user={user} ready={userReady} />
      <div className="sticky top-0 z-30 h-14 bg-background/80 backdrop-blur border-b border-border">
        <div className="relative h-full px-4">
          <>
            <div className="absolute right-4 top-1/2 -translate-y-1/2">
              <Sheet>
                <SheetTrigger asChild>
                  <Button size="icon" variant="outline">
                    <Menu className="h-4 w-4" />
                  </Button>
                </SheetTrigger>
                <SheetContent side="right" className="w-72 bg-sidebar text-sidebar-foreground border-l border-sidebar-border p-0">
                  <SheetTitle className="sr-only">منوی ناوبری</SheetTitle>
                  <SidebarContent
                    pathname={pathname}
                    user={user}
                    ready={userReady}
                  />
                </SheetContent>
              </Sheet>
            </div>
            <div className="absolute left-4 top-1/2 -translate-y-1/2">
              <Button
                size="icon"
                variant="outline"
                onClick={() => setTheme(isDark ? "light" : "dark")}
                aria-label={isDark ? "تغییر به تم روشن" : "تغییر به تم تیره"}
              >
                {isDark ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
              </Button>
            </div>
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 flex items-center gap-2">
              <div className="flex h-28 w-28 items-center justify-center">
                <Image src="/fanap.png" alt="لوگو فناپ" width={96} height={96} className="h-24 w-24 object-contain" />
              </div>
              <span className="text-sm font-semibold">سامانه توقفات</span>
            </div>
          </>
        </div>
      </div>
      <main className="min-h-screen lg:mr-64 pt-4 lg:pt-0">
        {children}
      </main>
    </div>
  )
}
