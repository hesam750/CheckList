"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Factory, Eye, EyeOff, Settings } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

export function LoginPage() {
  const router = useRouter()
  const [showPassword, setShowPassword] = useState(false)
  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    router.push("/dashboard")
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background relative overflow-hidden">
      <div className="absolute inset-0">
        <div className="absolute right-[-140px] top-[-120px] h-[420px] w-[420px] rounded-full border border-primary/20 bg-primary/5" />
        <div className="absolute left-[-160px] bottom-[-140px] h-[520px] w-[520px] rounded-full border border-primary/10 bg-primary/5" />
        <Settings className="gear-spin absolute right-[10%] top-[12%] h-40 w-40 text-primary/10" />
        <Settings className="gear-spin-slow absolute left-[12%] bottom-[15%] h-56 w-56 text-primary/10" />
      </div>

      <div className="relative w-full max-w-md mx-4">
        <div className="rounded-2xl border border-border bg-card/90 p-8 shadow-lg backdrop-blur">
          <div className="flex flex-col items-center mb-8">
            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary mb-4">
              <Factory className="h-8 w-8 text-primary-foreground" />
            </div>
            <h1 className="text-xl font-bold text-card-foreground text-balance text-center">سامانه مدیریت توقفات</h1>
            <p className="text-sm text-muted-foreground mt-1">ورود به سیستم مدیریت خطوط تولید</p>
          </div>

          <form onSubmit={handleLogin} className="space-y-5">
            <div className="space-y-2">
              <Label htmlFor="username" className="text-card-foreground">نام کاربری</Label>
              <Input
                id="username"
                placeholder="نام کاربری خود را وارد کنید"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password" className="text-card-foreground">رمز عبور</Label>
              <div className="relative">
                <Input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  placeholder="رمز عبور خود را وارد کنید"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-10 bg-secondary text-secondary-foreground placeholder:text-muted-foreground"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <Button type="submit" className="w-full bg-primary text-primary-foreground hover:bg-primary/90 h-11">
              ورود به سیستم
            </Button>
          </form>
        </div>
      </div>
    </div>
  )
}
