"use client"

import { useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Line,
  ComposedChart,
} from "recharts"
import { causeParetoData } from "@/lib/mock-data"

export default function ReportsPage() {
  const [period, setPeriod] = useState("month")

  // Calculate cumulative percentage for Pareto line
  const totalCount = causeParetoData.reduce((sum, d) => sum + d.count, 0)
  let cumulative = 0
  const paretoChartData = causeParetoData.map((item) => {
    cumulative += item.count
    return {
      ...item,
      cumulativePercent: Math.round((cumulative / totalCount) * 100),
    }
  })

  return (
    <AppLayout>
      <div className="p-6 space-y-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold text-foreground">گزارش علت توقفات</h1>
            <p className="text-sm text-muted-foreground mt-1">تحلیل پارتو علل توقف خطوط تولید</p>
          </div>
          <div className="flex items-center gap-3">
            <Select value={period} onValueChange={setPeriod}>
              <SelectTrigger className="w-44 bg-card text-card-foreground border-border">
                <SelectValue placeholder="بازه زمانی" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="week">هفته اخیر</SelectItem>
                <SelectItem value="month">ماه اخیر</SelectItem>
                <SelectItem value="quarter">سه ماه اخیر</SelectItem>
                <SelectItem value="year">سال جاری</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Pareto Chart */}
        <Card className="bg-card border-border">
          <CardHeader className="pb-2">
            <CardTitle className="text-base font-semibold text-card-foreground">
              نمودار پارتو علل توقف
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={paretoChartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis
                    dataKey="cause"
                    tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 10 }}
                    axisLine={{ stroke: "hsl(var(--border))" }}
                    angle={0}
                    interval={0}
                  />
                  <YAxis
                    yAxisId="left"
                    tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 11 }}
                    axisLine={{ stroke: "hsl(var(--border))" }}
                  />
                  <YAxis
                    yAxisId="right"
                    orientation="left"
                    tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 11 }}
                    axisLine={{ stroke: "hsl(var(--border))" }}
                    domain={[0, 100]}
                    tickFormatter={(v) => `${v}%`}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                      color: "hsl(var(--card-foreground))",
                      direction: "rtl",
                    }}
                    formatter={(value: number, name: string) => {
                      if (name === "تعداد") return [`${value} مورد`, name]
                      if (name === "درصد تجمعی") return [`${value}%`, name]
                      return [value, name]
                    }}
                  />
                  <Bar
                    yAxisId="left"
                    dataKey="count"
                    name="تعداد"
                    fill="hsl(var(--chart-1))"
                    radius={[4, 4, 0, 0]}
                  />
                  <Line
                    yAxisId="right"
                    type="monotone"
                    dataKey="cumulativePercent"
                    name="درصد تجمعی"
                    stroke="hsl(var(--chart-2))"
                    strokeWidth={2.5}
                    dot={{ fill: "hsl(var(--chart-2))", r: 4 }}
                  />
                </ComposedChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <Card className="bg-card border-border">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">بیشترین علت</p>
              <p className="text-lg font-bold text-card-foreground mt-1">{causeParetoData[0].cause}</p>
              <p className="text-xs text-muted-foreground mt-1">
                {causeParetoData[0].count} مورد ({causeParetoData[0].percentage}%)
              </p>
            </CardContent>
          </Card>
          <Card className="bg-card border-border">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">کل زمان توقف</p>
              <p className="text-lg font-bold text-card-foreground mt-1">
                {causeParetoData.reduce((s, d) => s + d.totalMinutes, 0).toLocaleString("fa-IR")} دقیقه
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                مجموع {causeParetoData.reduce((s, d) => s + d.count, 0)} مورد توقف
              </p>
            </CardContent>
          </Card>
          <Card className="bg-card border-border">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">{'قاعده ۸۰/۲۰'}</p>
              <p className="text-lg font-bold text-accent mt-1">۳ علت اصلی</p>
              <p className="text-xs text-muted-foreground mt-1">
                ۶۴% کل توقفات را تشکیل می‌دهند
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Detail Table */}
        <Card className="bg-card border-border">
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-semibold text-card-foreground">
              جدول تفصیلی علل توقف
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="border-border hover:bg-transparent">
                    <TableHead className="text-right text-muted-foreground">ردیف</TableHead>
                    <TableHead className="text-right text-muted-foreground">علت توقف</TableHead>
                    <TableHead className="text-right text-muted-foreground">تعداد</TableHead>
                    <TableHead className="text-right text-muted-foreground">{'مجموع زمان (دقیقه)'}</TableHead>
                    <TableHead className="text-right text-muted-foreground">{'میانگین (دقیقه)'}</TableHead>
                    <TableHead className="text-right text-muted-foreground">درصد</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {causeParetoData.map((item, index) => (
                    <TableRow key={item.cause} className="border-border">
                      <TableCell className="text-card-foreground text-sm">{index + 1}</TableCell>
                      <TableCell className="text-card-foreground text-sm font-medium">{item.cause}</TableCell>
                      <TableCell className="text-card-foreground text-sm">{item.count}</TableCell>
                      <TableCell className="text-card-foreground text-sm">{item.totalMinutes.toLocaleString("fa-IR")}</TableCell>
                      <TableCell className="text-card-foreground text-sm">{Math.round(item.totalMinutes / item.count)}</TableCell>
                      <TableCell className="text-card-foreground text-sm">{item.percentage}%</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  )
}
