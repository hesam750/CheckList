"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts"
import { unitComparisonData } from "@/lib/mock-data"

export function UnitComparisonChart() {
  return (
    <Card className="bg-card border-border">
      <CardHeader className="pb-2">
        <CardTitle className="text-base font-semibold text-card-foreground">
          مقایسه واحدها
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={unitComparisonData} barGap={4}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis
                dataKey="unit"
                tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 11 }}
                axisLine={{ stroke: "hsl(var(--border))" }}
              />
              <YAxis
                tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 11 }}
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
              />
              <Legend
                wrapperStyle={{ direction: "rtl", fontSize: 12 }}
              />
              <Bar
                dataKey="mtbf"
                name="MTBF"
                fill="hsl(var(--chart-1))"
                radius={[4, 4, 0, 0]}
              />
              <Bar
                dataKey="mttr"
                name="MTTR"
                fill="hsl(var(--chart-2))"
                radius={[4, 4, 0, 0]}
              />
              <Bar
                dataKey="availability"
                name="دسترس‌پذیری (%)"
                fill="hsl(var(--chart-3))"
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  )
}
