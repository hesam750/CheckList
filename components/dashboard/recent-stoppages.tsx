"use client"

import { useEffect, useMemo, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import type { Stoppage, StoppageStatus } from "@/lib/types"

const statusMap: Record<StoppageStatus, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  pending_supervisor: { label: "منتظر تایید سرپرست", variant: "outline" },
  pending_inspector: { label: "منتظر تایید ناظر", variant: "secondary" },
  approved: { label: "تایید شده", variant: "default" },
  rejected: { label: "رد شده", variant: "destructive" },
}

export function RecentStoppagesTable() {
  const [items, setItems] = useState<Stoppage[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch("/api/stoppages")
      .then((res) => (res.ok ? res.json() : []))
      .then((data) => setItems(Array.isArray(data) ? data : []))
      .finally(() => setLoading(false))
  }, [])

  const latestItems = useMemo(() => {
    if (!items.length) return []
    const getYear = (value?: string) => {
      if (!value) return null
      const parts = value.split("/")
      if (parts.length < 1) return null
      const year = Number.parseInt(parts[0], 10)
      return Number.isNaN(year) ? null : year
    }
    const getSortValue = (date?: string, time?: string) => {
      if (!date) return 0
      const parts = date.split("/")
      if (parts.length < 3) return 0
      const year = Number.parseInt(parts[0], 10)
      const month = Number.parseInt(parts[1], 10)
      const day = Number.parseInt(parts[2], 10)
      if ([year, month, day].some((value) => Number.isNaN(value))) return 0
      const timeParts = (time || "").split(":")
      const hour = Number.parseInt(timeParts[0] ?? "0", 10)
      const minute = Number.parseInt(timeParts[1] ?? "0", 10)
      const hourValue = Number.isNaN(hour) ? 0 : hour
      const minuteValue = Number.isNaN(minute) ? 0 : minute
      return year * 100000000 + month * 1000000 + day * 10000 + hourValue * 100 + minuteValue
    }
    const years = items
      .map((item) => getYear(item.endDate) ?? getYear(item.startDate))
      .filter((year): year is number => year !== null)
    const latestYear = years.length ? Math.max(...years) : null
    const filtered =
      latestYear === null
        ? items
        : items.filter((item) => (getYear(item.endDate) ?? getYear(item.startDate)) === latestYear)
    return filtered
      .slice()
      .sort((a, b) => {
        const aValue = getSortValue(a.endDate ?? a.startDate, a.endClock ?? a.startClock)
        const bValue = getSortValue(b.endDate ?? b.startDate, b.endClock ?? b.startClock)
        return bValue - aValue
      })
      .slice(0, 6)
  }, [items])

  return (
    <Card className="bg-card border-border">
      <CardHeader className="pb-3">
        <CardTitle className="text-base font-semibold text-card-foreground">
          آخرین توقفات ثبت شده
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow className="border-border hover:bg-transparent">
                <TableHead className="text-right text-muted-foreground">واحد</TableHead>
                <TableHead className="text-right text-muted-foreground">ماشین</TableHead>
                <TableHead className="text-right text-muted-foreground">نوع توقف</TableHead>
                <TableHead className="text-right text-muted-foreground">شروع</TableHead>
                <TableHead className="text-right text-muted-foreground">مدت</TableHead>
                <TableHead className="text-right text-muted-foreground">وضعیت</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow className="border-border">
                  <TableCell colSpan={6} className="text-center text-sm text-muted-foreground">
                    در حال بارگذاری...
                  </TableCell>
                </TableRow>
              ) : latestItems.length ? (
                latestItems.map((stoppage) => {
                  const status = statusMap[stoppage.status]
                  const durationText =
                    stoppage.durationMinutes !== undefined
                      ? `${Math.round(stoppage.durationMinutes)} دقیقه`
                      : "—"
                  return (
                    <TableRow key={stoppage.id} className="border-border">
                      <TableCell className="text-card-foreground text-sm">{stoppage.unit}</TableCell>
                      <TableCell className="text-card-foreground text-sm">{stoppage.machine}</TableCell>
                      <TableCell className="text-card-foreground text-sm">{stoppage.type}</TableCell>
                      <TableCell className="text-muted-foreground text-sm font-mono" dir="ltr">
                        {stoppage.startTime}
                      </TableCell>
                      <TableCell className="text-card-foreground text-sm">{durationText}</TableCell>
                      <TableCell>
                        <Badge variant={status.variant} className="text-xs whitespace-nowrap">
                          {status.label}
                        </Badge>
                      </TableCell>
                    </TableRow>
                  )
                })
              ) : (
                <TableRow className="border-border">
                  <TableCell colSpan={6} className="text-center text-sm text-muted-foreground">
                    توقفی ثبت نشده است
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  )
}
