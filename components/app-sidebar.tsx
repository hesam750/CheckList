"use client"

import Link from "next/link"
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
  Factory,
  Moon,
  Sun,
  Menu,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { Switch } from "@/components/ui/switch"
import { Sheet, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Button } from "@/components/ui/button"

const navItems = [
  { href: "/dashboard", label: "داشبورد", icon: LayoutDashboard },
  { href: "/stoppages/new", label: "ثبت توقف", icon: AlertTriangle },
  { href: "/stoppages/approve", label: "تایید توقف‌ها", icon: CheckSquare },
  { href: "/reports", label: "گزارش علت توقف", icon: BarChart3 },
  { href: "/settings", label: "مدیریت پایه", icon: Settings },
]

function SidebarContent({
  pathname,
  isDark,
  onThemeChange,
}: {
  pathname: string | null
  isDark: boolean
  onThemeChange: (checked: boolean) => void
}) {
  return (
    <>
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
        <div className="flex items-center justify-between rounded-lg px-3 py-2.5 mb-2 bg-sidebar-accent text-sidebar-accent-foreground">
          <div className="flex items-center gap-2 text-xs">
            {isDark ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
            تم
          </div>
          <Switch
            checked={isDark}
            onCheckedChange={onThemeChange}
          />
        </div>
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
    </>
  )
}

export function AppSidebar() {
  const pathname = usePathname()
  const { theme, setTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const isDark = theme === "dark"

  return (
    <aside className="fixed right-0 top-0 z-40 hidden h-screen w-64 flex-col bg-sidebar text-sidebar-foreground border-l border-sidebar-border lg:flex">
      {mounted && (
        <SidebarContent
          pathname={pathname}
          isDark={isDark}
          onThemeChange={(checked) => setTheme(checked ? "dark" : "light")}
        />
      )}
    </aside>
  )
}

export function AppLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const { theme, setTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const isDark = theme === "dark"

  return (
    <div className="min-h-screen bg-background">
      <AppSidebar />
      <div className="sticky top-0 z-30 h-14 bg-background/80 backdrop-blur border-b border-border">
        <div className="relative h-full px-4">
          {mounted && (
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
                      isDark={isDark}
                      onThemeChange={(checked) => setTheme(checked ? "dark" : "light")}
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
                <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary">
                  <Factory className="h-4 w-4 text-primary-foreground" />
                </div>
                <span className="text-sm font-semibold">سامانه توقفات</span>
              </div>
            </>
          )}
        </div>
      </div>
      <main className="min-h-screen lg:mr-64 pt-4 lg:pt-0">
        {children}
      </main>
    </div>
  )
}
