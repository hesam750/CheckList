"use client"

import { useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { KPICards } from "@/components/dashboard/kpi-cards"
import { MonthlyTrendChart } from "@/components/dashboard/monthly-trend-chart"
import { UnitComparisonChart } from "@/components/dashboard/unit-comparison-chart"
import { RecentStoppagesTable } from "@/components/dashboard/recent-stoppages"
import { overviewKPI } from "@/lib/mock-data"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

export default function DashboardPage() {
  const [selectedMonth, setSelectedMonth] = useState("all")
  const [selectedUnit, setSelectedUnit] = useState("all")

  return (
    <AppLayout>
      <div className="p-6 space-y-6">
        {/* Header */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold text-foreground">داشبورد مدیریتی</h1>
            <p className="text-sm text-muted-foreground mt-1">نمای کلی عملکرد خطوط تولید</p>
          </div>
          <div className="flex items-center gap-3">
            <Select value={selectedMonth} onValueChange={setSelectedMonth}>
              <SelectTrigger className="w-36 bg-card text-card-foreground border-border">
                <SelectValue placeholder="ماه" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">همه ماه‌ها</SelectItem>
                <SelectItem value="bahman">بهمن ۱۴۰۴</SelectItem>
                <SelectItem value="dey">دی ۱۴۰۴</SelectItem>
                <SelectItem value="azar">آذر ۱۴۰۴</SelectItem>
                <SelectItem value="aban">آبان ۱۴۰۴</SelectItem>
              </SelectContent>
            </Select>
            <Select value={selectedUnit} onValueChange={setSelectedUnit}>
              <SelectTrigger className="w-36 bg-card text-card-foreground border-border">
                <SelectValue placeholder="واحد" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">همه واحدها</SelectItem>
                <SelectItem value="u1">واحد تولید ۱</SelectItem>
                <SelectItem value="u2">واحد تولید ۲</SelectItem>
                <SelectItem value="u3">واحد تولید ۳</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* KPI Cards */}
        <KPICards data={overviewKPI} />

        {/* Charts */}
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <MonthlyTrendChart />
          <UnitComparisonChart />
        </div>

        {/* Recent stoppages */}
        <RecentStoppagesTable />
      </div>
    </AppLayout>
  )
}
