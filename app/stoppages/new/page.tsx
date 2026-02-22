"use client"

import { useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { units, stoppageTypes, stoppageCauses, shifts } from "@/lib/mock-data"
import { Save, RotateCcw } from "lucide-react"

export default function NewStoppagePage() {
  const [selectedUnit, setSelectedUnit] = useState("")
  const [selectedLine, setSelectedLine] = useState("")
  const [selectedMachine, setSelectedMachine] = useState("")
  const [selectedShift, setSelectedShift] = useState("")
  const [stoppageCode, setStoppageCode] = useState("")
  const [startDate, setStartDate] = useState("")
  const [startClock, setStartClock] = useState("")
  const [endDate, setEndDate] = useState("")
  const [endClock, setEndClock] = useState("")
  const [stoppageType, setStoppageType] = useState("")
  const [cause, setCause] = useState("")
  const [description, setDescription] = useState("")
  const [submitted, setSubmitted] = useState(false)

  const currentUnit = units.find((u) => u.id === selectedUnit)
  const currentLine = currentUnit?.lines.find((l) => l.id === selectedLine)
  const currentMachine = currentLine?.machines.find((m) => m.id === selectedMachine)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setSubmitted(true)
    setTimeout(() => setSubmitted(false), 3000)
  }

  const handleReset = () => {
    setSelectedUnit("")
    setSelectedLine("")
    setSelectedMachine("")
    setSelectedShift("")
    setStoppageCode("")
    setStartDate("")
    setStartClock("")
    setEndDate("")
    setEndClock("")
    setStoppageType("")
    setCause("")
    setDescription("")
  }

  const durationMinutes = (() => {
    if (!startDate || !startClock || !endDate || !endClock) return ""
    const start = new Date(`${startDate}T${startClock}`)
    const end = new Date(`${endDate}T${endClock}`)
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) return ""
    if (end < start) return ""
    return Math.round((end.getTime() - start.getTime()) / 60000).toString()
  })()

  const requiredFields = [
    selectedUnit,
    selectedLine,
    selectedMachine,
    selectedShift,
    stoppageCode,
    startDate,
    startClock,
    endDate,
    endClock,
    stoppageType,
    cause,
  ]
  const filledCount = requiredFields.filter(Boolean).length
  const completion = Math.round((filledCount / requiredFields.length) * 100)
  const step1Done = Boolean(selectedUnit && selectedLine && selectedMachine && selectedShift)
  const step2Done = Boolean(stoppageCode && startDate && startClock && endDate && endClock)
  const step3Done = Boolean(stoppageType && cause)

  return (
    <AppLayout>
      <div className="p-6 space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-foreground">ثبت توقف جدید</h1>
          <p className="text-sm text-muted-foreground mt-1">اطلاعات توقف خط تولید را وارد نمایید</p>
        </div>

        {submitted && (
          <div className="rounded-lg bg-success/10 border border-success/20 p-4 text-sm text-success">
            توقف با موفقیت ثبت شد و برای تایید سرپرست ارسال گردید.
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <div className="space-y-6 lg:col-span-2">
              <div className="grid grid-cols-1 gap-6">
                <Card className="bg-card border-border">
                  <CardHeader className="pb-4">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-base font-semibold text-card-foreground">اطلاعات محل توقف</CardTitle>
                      <Badge variant="outline" className="border-border">مرحله ۱</Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label className="text-card-foreground">واحد</Label>
                      <Select value={selectedUnit} onValueChange={(v) => { setSelectedUnit(v); setSelectedLine(""); setSelectedMachine(""); }}>
                        <SelectTrigger className="bg-secondary text-secondary-foreground">
                          <SelectValue placeholder="واحد را انتخاب کنید" />
                        </SelectTrigger>
                        <SelectContent>
                          {units.map((u) => (
                            <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-card-foreground">خط تولید</Label>
                      <Select value={selectedLine} onValueChange={(v) => { setSelectedLine(v); setSelectedMachine(""); }} disabled={!selectedUnit}>
                        <SelectTrigger className="bg-secondary text-secondary-foreground">
                          <SelectValue placeholder="خط تولید را انتخاب کنید" />
                        </SelectTrigger>
                        <SelectContent>
                          {currentUnit?.lines.map((l) => (
                            <SelectItem key={l.id} value={l.id}>{l.name}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-card-foreground">ماشین / دستگاه</Label>
                      <Select value={selectedMachine} onValueChange={setSelectedMachine} disabled={!selectedLine}>
                        <SelectTrigger className="bg-secondary text-secondary-foreground">
                          <SelectValue placeholder="ماشین را انتخاب کنید" />
                        </SelectTrigger>
                        <SelectContent>
                          {currentLine?.machines.map((m) => (
                            <SelectItem key={m.id} value={m.id}>{m.name}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-card-foreground">شیفت</Label>
                      <Select value={selectedShift} onValueChange={setSelectedShift}>
                        <SelectTrigger className="bg-secondary text-secondary-foreground">
                          <SelectValue placeholder="شیفت را انتخاب کنید" />
                        </SelectTrigger>
                        <SelectContent>
                          {shifts.map((s) => (
                            <SelectItem key={s} value={s}>{s}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </CardContent>
                </Card>

                <Card className={`bg-card border-border ${step1Done ? "" : "opacity-60 pointer-events-none"}`}>
                  <CardHeader className="pb-4">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-base font-semibold text-card-foreground">اطلاعات زمان توقف</CardTitle>
                      <Badge variant="outline" className="border-border">مرحله ۲</Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label className="text-card-foreground">کد توقف</Label>
                      <Input
                        value={stoppageCode}
                        onChange={(e) => setStoppageCode(e.target.value)}
                        className="bg-secondary text-secondary-foreground"
                        placeholder="کد توقف را وارد کنید"
                        disabled={!step1Done}
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label className="text-card-foreground">تاریخ توقف</Label>
                        <Input
                          type="date"
                          value={startDate}
                          onChange={(e) => setStartDate(e.target.value)}
                          className="bg-secondary text-secondary-foreground"
                          dir="ltr"
                          disabled={!step1Done}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label className="text-card-foreground">زمان شروع توقف</Label>
                        <Input
                          type="time"
                          value={startClock}
                          onChange={(e) => setStartClock(e.target.value)}
                          className="bg-secondary text-secondary-foreground"
                          dir="ltr"
                          disabled={!step1Done}
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label className="text-card-foreground">تاریخ پایان توقف</Label>
                        <Input
                          type="date"
                          value={endDate}
                          onChange={(e) => setEndDate(e.target.value)}
                          className="bg-secondary text-secondary-foreground"
                          dir="ltr"
                          disabled={!step1Done}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label className="text-card-foreground">زمان پایان توقف</Label>
                        <Input
                          type="time"
                          value={endClock}
                          onChange={(e) => setEndClock(e.target.value)}
                          className="bg-secondary text-secondary-foreground"
                          dir="ltr"
                          disabled={!step1Done}
                        />
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-card-foreground">مدت توقف (دقیقه)</Label>
                      <Input
                        value={durationMinutes}
                        readOnly
                        className="bg-secondary text-secondary-foreground"
                        dir="ltr"
                        disabled={!step1Done}
                      />
                    </div>
                  </CardContent>
                </Card>

                <Card className={`bg-card border-border ${step1Done && step2Done ? "" : "opacity-60 pointer-events-none"}`}>
                  <CardHeader className="pb-4">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-base font-semibold text-card-foreground">اطلاعات علت توقف</CardTitle>
                      <Badge variant="outline" className="border-border">مرحله ۳</Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label className="text-card-foreground">نوع توقف</Label>
                      <Select value={stoppageType} onValueChange={setStoppageType} disabled={!step1Done || !step2Done}>
                        <SelectTrigger className="bg-secondary text-secondary-foreground">
                          <SelectValue placeholder="نوع توقف را انتخاب کنید" />
                        </SelectTrigger>
                        <SelectContent>
                          {stoppageTypes.map((t) => (
                            <SelectItem key={t} value={t}>{t}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-card-foreground">علت توقف</Label>
                      <Select value={cause} onValueChange={setCause} disabled={!step1Done || !step2Done}>
                        <SelectTrigger className="bg-secondary text-secondary-foreground">
                          <SelectValue placeholder="علت توقف را انتخاب کنید" />
                        </SelectTrigger>
                        <SelectContent>
                          {stoppageCauses.map((c) => (
                            <SelectItem key={c} value={c}>{c}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-card-foreground">توضیحات</Label>
                      <Textarea
                        placeholder="توضیحات تکمیلی در مورد توقف..."
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        rows={3}
                        className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground resize-none"
                        disabled={!step1Done || !step2Done}
                      />
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>

            <div className="space-y-6">
              <Card className="bg-card border-border">
                <CardHeader className="pb-4">
                  <CardTitle className="text-base font-semibold text-card-foreground">وضعیت تکمیل فرم</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-muted-foreground">میزان تکمیل</span>
                    <span className="text-card-foreground font-semibold">{completion}%</span>
                  </div>
                  <Progress value={completion} className="h-2 bg-secondary" />
                  <div className="rounded-lg border border-border p-3 space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">واحد</span>
                      <span className="text-card-foreground">{currentUnit?.name ?? "—"}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">خط</span>
                      <span className="text-card-foreground">{currentLine?.name ?? "—"}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">ماشین</span>
                      <span className="text-card-foreground">{currentMachine?.name ?? "—"}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">شیفت</span>
                      <span className="text-card-foreground">{selectedShift || "—"}</span>
                    </div>
                  </div>
                  <div className="rounded-lg border border-border p-3 space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">نوع توقف</span>
                      <span className="text-card-foreground">{stoppageType || "—"}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">علت توقف</span>
                      <span className="text-card-foreground">{cause || "—"}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">مدت توقف</span>
                      <span className="text-card-foreground">{durationMinutes ? `${durationMinutes} دقیقه` : "—"}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-3 mt-6">
            <Button
              type="submit"
              className="bg-primary text-primary-foreground hover:bg-primary/90"
              disabled={!step1Done || !step2Done || !step3Done}
            >
              <Save className="ml-2 h-4 w-4" />
              ثبت توقف
            </Button>
            <Button type="button" variant="outline" onClick={handleReset} className="border-border text-foreground hover:bg-secondary">
              <RotateCcw className="ml-2 h-4 w-4" />
              پاک کردن فرم
            </Button>
          </div>
        </form>
      </div>
    </AppLayout>
  )
}
