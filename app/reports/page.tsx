"use client"

import { useMemo, useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
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
  LabelList,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Line,
  ComposedChart,
} from "recharts"
import { causeParetoData, mockStoppages } from "@/lib/mock-data"

const wrapLines = (value: string, maxChars: number) => {
  const words = value.split(" ")
  const lines: string[] = []
  let current = ""
  words.forEach((word) => {
    const next = current ? `${current} ${word}` : word
    if (next.length <= maxChars) {
      current = next
    } else {
      if (current) lines.push(current)
      current = word
    }
  })
  if (current) lines.push(current)
  if (!lines.length) return [value]
  if (lines.length > 2) {
    const trimmed = lines.slice(0, 2)
    trimmed[1] = trimmed[1].length > maxChars ? `${trimmed[1].slice(0, maxChars - 1)}…` : trimmed[1]
    return trimmed
  }
  return lines
}

type YAxisTickProps = { x?: number; y?: number; payload?: { value?: string } }

const YAxisTick = ({ x = 0, y = 0, payload }: YAxisTickProps) => {
  const value = payload?.value ?? ""
  const lines = wrapLines(value, 18)
  return (
    <g transform={`translate(${x},${y})`}>
      <text x={0} y={0} dy={4} textAnchor="end" fill="hsl(var(--muted-foreground))" fontSize={12}>
        {lines.map((line, index) => (
          <tspan key={`${value}-${index}`} x={0} dy={index === 0 ? 0 : 14}>
            {line}
          </tspan>
        ))}
      </text>
    </g>
  )
}

export default function ReportsPage() {
  const [period, setPeriod] = useState("month")
  const [viewMode, setViewMode] = useState<"all" | "focus">("all")
  const [reportType, setReportType] = useState<"table" | "charts">("table")
  const [chartLimit, setChartLimit] = useState("10")

  const totalCount = causeParetoData.reduce((sum, d) => sum + d.count, 0)
  const topCause = causeParetoData[0]
  const top3Percent = totalCount
    ? Math.round(
        (causeParetoData.slice(0, 3).reduce((sum, item) => sum + item.count, 0) / totalCount) * 100
      )
    : 0
  const maxChartItems = 12
  const chartItems = causeParetoData.slice(0, maxChartItems)
  const otherItems = causeParetoData.slice(maxChartItems)
  const other =
    otherItems.length > 0
      ? {
          cause: "سایر",
          count: otherItems.reduce((sum, item) => sum + item.count, 0),
          totalMinutes: otherItems.reduce((sum, item) => sum + item.totalMinutes, 0),
          percentage: totalCount
            ? Math.round(
                (otherItems.reduce((sum, item) => sum + item.count, 0) / totalCount) * 100
              )
            : 0,
        }
      : null
  const paretoSource = other ? [...chartItems, other] : chartItems
  const cumulativeCounts = paretoSource.reduce<number[]>((acc, item) => {
    const previous = acc[acc.length - 1] ?? 0
    return [...acc, previous + item.count]
  }, [])
  const paretoChartData = paretoSource.map((item, index) => ({
    ...item,
    cumulativePercent: totalCount
      ? Math.round((cumulativeCounts[index] / totalCount) * 100)
      : 0,
  }))

  const unitSummaries = useMemo(() => {
    const buildCauseStats = (items: typeof mockStoppages) => {
      const causeMap = new Map<string, { cause: string; count: number; totalMinutes: number }>()
      let totalMinutes = 0
      items.forEach((item) => {
        const key = item.cause || "نامشخص"
        if (!causeMap.has(key)) {
          causeMap.set(key, { cause: key, count: 0, totalMinutes: 0 })
        }
        const entry = causeMap.get(key)!
        entry.count += 1
        const minutes = item.durationMinutes ?? 0
        entry.totalMinutes += minutes
        totalMinutes += minutes
      })
      const totalCount = items.length
      const sorted = Array.from(causeMap.values()).sort((a, b) => b.count - a.count)
      const top = sorted[0]
      const topCausePercent = totalCount ? Math.round(((top?.count ?? 0) / totalCount) * 100) : 0
      return {
        totalCount,
        totalMinutes: Math.round(totalMinutes),
        topCause: top?.cause ?? "—",
        topCauseCount: top?.count ?? 0,
        topCausePercent,
        topCauses: sorted.slice(0, 3),
        causes: sorted,
      }
    }

    const unitMap = new Map<string, { items: typeof mockStoppages; machines: Map<string, typeof mockStoppages> }>()
    mockStoppages.forEach((item) => {
      const unitName = item.unit || "نامشخص"
      if (!unitMap.has(unitName)) {
        unitMap.set(unitName, { items: [], machines: new Map() })
      }
      const unitEntry = unitMap.get(unitName)!
      unitEntry.items.push(item)
      const machineName = item.machine || "نامشخص"
      if (!unitEntry.machines.has(machineName)) {
        unitEntry.machines.set(machineName, [])
      }
      unitEntry.machines.get(machineName)!.push(item)
    })

    return Array.from(unitMap.entries()).map(([unit, entry]) => {
      const unitStats = buildCauseStats(entry.items)
      const machines = Array.from(entry.machines.entries())
        .map(([machine, items]) => {
          const stats = buildCauseStats(items)
          return {
            machine,
            totalCount: stats.totalCount,
            totalMinutes: stats.totalMinutes,
            topCause: stats.topCause,
            topCauseCount: stats.topCauseCount,
            topCausePercent: stats.topCausePercent,
            topCauses: stats.topCauses,
            causes: stats.causes,
          }
        })
        .sort((a, b) => b.totalCount - a.totalCount)
      return {
        unit,
        ...unitStats,
        machines,
      }
    })
  }, [])

  const limitValue = Number.parseInt(chartLimit, 10) || 10
  const buildChartCauses = (causes: { cause: string; count: number; totalMinutes: number }[]) => {
    const main = causes.slice(0, limitValue)
    const rest = causes.slice(limitValue)
    if (!rest.length) return main
    return [
      ...main,
      {
        cause: "سایر",
        count: rest.reduce((sum, item) => sum + item.count, 0),
        totalMinutes: rest.reduce((sum, item) => sum + item.totalMinutes, 0),
      },
    ]
  }

  return (
    <AppLayout>
      <div className="p-6 space-y-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold text-foreground">گزارش علت توقفات</h1>
            <p className="text-sm text-muted-foreground mt-1">تحلیل پارتو علل توقف خطوط تولید</p>
          </div>
          <div className="flex items-center gap-3">
            <Select value={reportType} onValueChange={(value) => setReportType(value as "table" | "charts")}>
              <SelectTrigger className="w-44 bg-card text-card-foreground border-border">
                <SelectValue placeholder="نوع گزارش" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="table">جدولی</SelectItem>
                <SelectItem value="charts">نمودار</SelectItem>
              </SelectContent>
            </Select>
            {reportType === "charts" && viewMode === "all" ? (
              <Select value={chartLimit} onValueChange={setChartLimit}>
                <SelectTrigger className="w-44 bg-card text-card-foreground border-border">
                  <SelectValue placeholder="علل در نمودار" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="6">۶ علت اول</SelectItem>
                  <SelectItem value="10">۱۰ علت اول</SelectItem>
                  <SelectItem value="15">۱۵ علت اول</SelectItem>
                </SelectContent>
              </Select>
            ) : null}
            <Select value={viewMode} onValueChange={(value) => setViewMode(value as "all" | "focus")}>
              <SelectTrigger className="w-44 bg-card text-card-foreground border-border">
                <SelectValue placeholder="حالت نمایش" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">نمایش کامل علل</SelectItem>
                <SelectItem value="focus">پارتو تمرکزی</SelectItem>
              </SelectContent>
            </Select>
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

        {viewMode === "all" ? (
          <Card className="bg-card border-border">
            <CardHeader className="pb-2">
              <CardTitle className="text-base font-semibold text-card-foreground">
                گزارش تفصیلی علل توقف به تفکیک سالن و دستگاه
              </CardTitle>
            </CardHeader>
            <CardContent>
              {reportType === "charts" ? (
                <div className="space-y-4">
                  {unitSummaries.map((unit) => {
                    const chartCauses = buildChartCauses(unit.causes)
                    const height = Math.min(900, Math.max(420, (chartCauses.length + 1) * 44))
                    return (
                      <Card key={unit.unit} className="bg-background border-border">
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base font-semibold text-card-foreground">
                            {unit.unit}
                          </CardTitle>
                        </CardHeader>
                        <CardContent>
                          <div className="mb-3 flex flex-wrap items-center gap-2 text-xs text-muted-foreground">
                            <Badge variant="outline" className="border-border">
                              {unit.totalCount} توقف
                            </Badge>
                            <Badge variant="outline" className="border-border">
                              رایج‌ترین: {unit.topCause}
                            </Badge>
                            <Badge variant="outline" className="border-border">
                              سهم: {unit.topCausePercent}%
                            </Badge>
                          </div>
                          <div style={{ height }}>
                            <ResponsiveContainer width="100%" height="100%">
                              <BarChart
                                data={chartCauses}
                                layout="vertical"
                                margin={{ left: 24, right: 72, top: 12, bottom: 12 }}
                                barCategoryGap={16}
                              >
                                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                                <XAxis
                                  type="number"
                                  tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 12 }}
                                  axisLine={{ stroke: "hsl(var(--border))" }}
                                />
                                <YAxis
                                  type="category"
                                  dataKey="cause"
                                  width={360}
                                  orientation="right"
                                  tick={(props) => <YAxisTick {...props} />}
                                  tickMargin={12}
                                  axisLine={{ stroke: "hsl(var(--border))" }}
                                />
                                <Tooltip
                                  contentStyle={{
                                    backgroundColor: "hsl(var(--card))",
                                    border: "1px solid hsl(var(--border))",
                                    borderRadius: "8px",
                                    color: "hsl(var(--card-foreground))",
                                    direction: "rtl",
                                  }}
                                  formatter={(value: number) => [`${value} مورد`, "تعداد"]}
                                  labelFormatter={(label) => `علت: ${label}`}
                                />
                                <Bar dataKey="count" name="تعداد" fill="hsl(var(--chart-1))" radius={[0, 6, 6, 0]} barSize={24}>
                                  <LabelList dataKey="count" position="right" fill="hsl(var(--muted-foreground))" fontSize={12} />
                                </Bar>
                              </BarChart>
                            </ResponsiveContainer>
                          </div>
                        </CardContent>
                      </Card>
                    )
                  })}
                </div>
              ) : (
                <div className="space-y-6">
                  {unitSummaries.map((unit) => (
                    <Card key={unit.unit} className="bg-background border-border">
                      <CardHeader className="pb-2">
                        <CardTitle className="text-base font-semibold text-card-foreground">
                          {unit.unit}
                        </CardTitle>
                      </CardHeader>
                      <CardContent className="space-y-4">
                        <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
                          <div className="rounded-lg border border-border p-3">
                            <p className="text-xs text-muted-foreground">تعداد توقفات</p>
                            <p className="text-lg font-semibold text-card-foreground">{unit.totalCount}</p>
                          </div>
                          <div className="rounded-lg border border-border p-3">
                            <p className="text-xs text-muted-foreground">رایج‌ترین علت</p>
                            <p className="text-sm font-semibold text-card-foreground">{unit.topCause}</p>
                            <p className="text-xs text-muted-foreground">
                              {unit.topCauseCount} مورد ({unit.topCausePercent}%)
                            </p>
                          </div>
                          <div className="rounded-lg border border-border p-3">
                            <p className="text-xs text-muted-foreground">مجموع زمان توقف</p>
                            <p className="text-lg font-semibold text-card-foreground">
                              {unit.totalMinutes.toLocaleString("fa-IR")} دقیقه
                            </p>
                          </div>
                        </div>
                        <div className="flex flex-wrap gap-2">
                          {unit.topCauses.map((cause) => (
                            <Badge key={cause.cause} variant="secondary" className="text-xs">
                              {cause.cause} ({cause.count})
                            </Badge>
                          ))}
                        </div>
                        <div className="overflow-x-auto">
                          <Table>
                            <TableHeader>
                              <TableRow className="border-border hover:bg-transparent">
                                <TableHead className="text-right text-muted-foreground">دستگاه</TableHead>
                                <TableHead className="text-right text-muted-foreground">تعداد توقف</TableHead>
                                <TableHead className="text-right text-muted-foreground">رایج‌ترین علت</TableHead>
                                <TableHead className="text-right text-muted-foreground">سهم علت</TableHead>
                                <TableHead className="text-right text-muted-foreground">مجموع زمان</TableHead>
                              </TableRow>
                            </TableHeader>
                            <TableBody>
                              {unit.machines.map((machine) => (
                                <TableRow key={`${unit.unit}-${machine.machine}`} className="border-border">
                                  <TableCell className="text-card-foreground text-sm">
                                    {machine.machine}
                                  </TableCell>
                                  <TableCell className="text-card-foreground text-sm">
                                    {machine.totalCount}
                                  </TableCell>
                                  <TableCell className="text-card-foreground text-sm">
                                    {machine.topCause}
                                  </TableCell>
                                  <TableCell className="text-card-foreground text-sm">
                                    {machine.topCausePercent}%
                                  </TableCell>
                                  <TableCell className="text-card-foreground text-sm">
                                    {machine.totalMinutes.toLocaleString("fa-IR")}
                                  </TableCell>
                                </TableRow>
                              ))}
                            </TableBody>
                          </Table>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        ) : (
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
        )}

        {/* Summary Cards */}
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <Card className="bg-card border-border">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">بیشترین علت</p>
              <p className="text-lg font-bold text-card-foreground mt-1">{topCause?.cause ?? "—"}</p>
              <p className="text-xs text-muted-foreground mt-1">
                {topCause?.count ?? 0} مورد ({topCause?.percentage ?? 0}%)
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
                {top3Percent}% کل توقفات را تشکیل می‌دهند
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
