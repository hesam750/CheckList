"use client"

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
import { mockStoppages } from "@/lib/mock-data"
import type { StoppageStatus } from "@/lib/types"

const statusMap: Record<StoppageStatus, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  pending_supervisor: { label: "منتظر تایید سرپرست", variant: "outline" },
  pending_inspector: { label: "منتظر تایید ناظر", variant: "secondary" },
  approved: { label: "تایید شده", variant: "default" },
  rejected: { label: "رد شده", variant: "destructive" },
}

export function RecentStoppagesTable() {
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
              {mockStoppages.slice(0, 6).map((stoppage) => {
                const status = statusMap[stoppage.status]
                return (
                  <TableRow key={stoppage.id} className="border-border">
                    <TableCell className="text-card-foreground text-sm">{stoppage.unit}</TableCell>
                    <TableCell className="text-card-foreground text-sm">{stoppage.machine}</TableCell>
                    <TableCell className="text-card-foreground text-sm">{stoppage.type}</TableCell>
                    <TableCell className="text-muted-foreground text-sm font-mono" dir="ltr">{stoppage.startTime}</TableCell>
                    <TableCell className="text-card-foreground text-sm">۷۵ دقیقه</TableCell>
                    <TableCell>
                      <Badge variant={status.variant} className="text-xs whitespace-nowrap">
                        {status.label}
                      </Badge>
                    </TableCell>
                  </TableRow>
                )
              })}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  )
}
