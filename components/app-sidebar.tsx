"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  LayoutDashboard,
  AlertTriangle,
  CheckSquare,
  BarChart3,
  Settings,
  LogOut,
  Factory,
} from "lucide-react"
import { cn } from "@/lib/utils"

const navItems = [
  { href: "/dashboard", label: "داشبورد", icon: LayoutDashboard },
  { href: "/stoppages/new", label: "ثبت توقف", icon: AlertTriangle },
  { href: "/stoppages/approve", label: "تایید توقف‌ها", icon: CheckSquare },
  { href: "/reports", label: "گزارش علت توقف", icon: BarChart3 },
  { href: "/settings", label: "مدیریت پایه", icon: Settings },
]

export function AppSidebar() {
  const pathname = usePathname()

  return (
    <aside className="fixed right-0 top-0 z-40 flex h-screen w-64 flex-col bg-sidebar text-sidebar-foreground border-l border-sidebar-border">
      <div className="flex items-center gap-3 px-6 py-5 border-b border-sidebar-border">
        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary">
          <Factory className="h-5 w-5 text-primary-foreground" />
        </div>
        <div>
          <h1 className="text-sm font-bold text-sidebar-foreground">سامانه توقفات</h1>
          <p className="text-xs text-sidebar-foreground/60">مدیریت خطوط تولید</p>
        </div>
      </div>

      <nav className="flex-1 px-3 py-4 space-y-1">
        {navItems.map((item) => {
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
            س‌ح
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-sidebar-foreground truncate">سعید حسینی</p>
            <p className="text-xs text-sidebar-foreground/50">مدیر سیستم</p>
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
    </aside>
  )
}

export function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-background">
      <AppSidebar />
      <main className="mr-64 min-h-screen">
        {children}
      </main>
    </div>
  )
}
