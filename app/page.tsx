"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Factory, Eye, EyeOff } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

export default function LoginPage() {
  const router = useRouter()
  const [showPassword, setShowPassword] = useState(false)
  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")
  const [unit, setUnit] = useState("")

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    router.push("/dashboard")
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background relative overflow-hidden">
      {/* Decorative background */}
      <div className="absolute inset-0 opacity-[0.03]">
        <div className="absolute top-20 right-20 w-72 h-72 rounded-full border-2 border-primary" />
        <div className="absolute bottom-20 left-20 w-96 h-96 rounded-full border border-primary" />
        <div className="absolute top-1/2 left-1/3 w-48 h-48 rounded-full border border-muted-foreground" />
      </div>

      <div className="relative w-full max-w-md mx-4">
        <div className="rounded-xl border border-border bg-card p-8 shadow-lg">
          {/* Logo */}
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

            <div className="space-y-2">
              <Label className="text-card-foreground">واحد سازمانی</Label>
              <Select value={unit} onValueChange={setUnit}>
                <SelectTrigger className="bg-secondary text-secondary-foreground">
                  <SelectValue placeholder="واحد خود را انتخاب کنید" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="unit1">واحد تولید ۱</SelectItem>
                  <SelectItem value="unit2">واحد تولید ۲</SelectItem>
                  <SelectItem value="unit3">واحد تولید ۳</SelectItem>
                  <SelectItem value="all">{'همه واحدها (مدیریت)'}</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Button type="submit" className="w-full bg-primary text-primary-foreground hover:bg-primary/90 h-11">
              ورود به سیستم
            </Button>
          </form>

          <p className="text-center text-xs text-muted-foreground mt-6">
            {'نسخه ۱.۰.۰ | طراحی و توسعه واحد فناوری اطلاعات'}
          </p>
        </div>
      </div>
    </div>
  )
}
