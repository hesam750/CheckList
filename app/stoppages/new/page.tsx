"use client"

import { useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
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
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            {/* Location Info */}
            <Card className="bg-card border-border">
              <CardHeader className="pb-4">
                <CardTitle className="text-base font-semibold text-card-foreground">اطلاعات محل توقف</CardTitle>
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

            {/* Time & Cause Info */}
            <Card className="bg-card border-border">
              <CardHeader className="pb-4">
                <CardTitle className="text-base font-semibold text-card-foreground">اطلاعات زمان و علت</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-card-foreground">کد توقف</Label>
                  <Input
                    value={stoppageCode}
                    onChange={(e) => setStoppageCode(e.target.value)}
                    className="bg-secondary text-secondary-foreground"
                    placeholder="کد توقف را وارد کنید"
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
                  />
                </div>

                <div className="space-y-2">
                  <Label className="text-card-foreground">نوع توقف</Label>
                  <Select value={stoppageType} onValueChange={setStoppageType}>
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
                  <Select value={cause} onValueChange={setCause}>
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
                  />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-3 mt-6">
            <Button type="submit" className="bg-primary text-primary-foreground hover:bg-primary/90">
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
