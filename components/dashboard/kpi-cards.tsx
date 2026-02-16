"use client"

import { Clock, AlertTriangle, TrendingUp, TrendingDown, Activity, Timer } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"
import type { KPIData } from "@/lib/types"

interface KPICardsProps {
  data: KPIData
}

export function KPICards({ data }: KPICardsProps) {
  const cards = [
    {
      title: "MTBF",
      value: `${data.mtbf} دقیقه`,
      target: `هدف: ${data.mtbfTarget} دقیقه`,
      icon: TrendingUp,
      trend: data.mtbf >= data.mtbfTarget ? "up" : "down",
      color: data.mtbf >= data.mtbfTarget ? "text-success" : "text-destructive",
      bgColor: data.mtbf >= data.mtbfTarget ? "bg-success/10" : "bg-destructive/10",
    },
    {
      title: "MTTR",
      value: `${data.mttr} دقیقه`,
      target: `هدف: ${data.mttrTarget} دقیقه`,
      icon: Timer,
      trend: data.mttr <= data.mttrTarget ? "up" : "down",
      color: data.mttr <= data.mttrTarget ? "text-success" : "text-destructive",
      bgColor: data.mttr <= data.mttrTarget ? "bg-success/10" : "bg-destructive/10",
    },
    {
      title: "دسترس‌پذیری",
      value: `${data.availability}%`,
      target: "هدف: ۸۵%",
      icon: Activity,
      trend: data.availability >= 85 ? "up" : "down",
      color: data.availability >= 85 ? "text-success" : "text-destructive",
      bgColor: data.availability >= 85 ? "bg-success/10" : "bg-destructive/10",
    },
    {
      title: "کل توقفات",
      value: `${data.totalStoppages} مورد`,
      target: `${data.totalDowntime} دقیقه زمان کل`,
      icon: AlertTriangle,
      trend: "neutral" as const,
      color: "text-accent",
      bgColor: "bg-accent/10",
    },
  ]

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {cards.map((card) => (
        <Card key={card.title} className="bg-card border-border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm text-muted-foreground">{card.title}</p>
                <p className="text-2xl font-bold text-card-foreground">{card.value}</p>
                <p className="text-xs text-muted-foreground">{card.target}</p>
              </div>
              <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${card.bgColor}`}>
                <card.icon className={`h-5 w-5 ${card.color}`} />
              </div>
            </div>
            {card.trend !== "neutral" && (
              <div className={`mt-3 flex items-center gap-1 text-xs ${card.color}`}>
                {card.trend === "up" ? (
                  <TrendingUp className="h-3 w-3" />
                ) : (
                  <TrendingDown className="h-3 w-3" />
                )}
                <span>{card.trend === "up" ? "در محدوده هدف" : "خارج از محدوده هدف"}</span>
              </div>
            )}
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
