"use client"

import { useState } from "react"
import { AppLayout } from "@/components/app-sidebar"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { mockStoppages } from "@/lib/mock-data"
import type { Stoppage, StoppageStatus } from "@/lib/types"
import { Check, X, Eye } from "lucide-react"

const statusMap: Record<StoppageStatus, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  pending_supervisor: { label: "منتظر تایید سرپرست", variant: "outline" },
  pending_inspector: { label: "منتظر تایید ناظر", variant: "secondary" },
  approved: { label: "تایید شده", variant: "default" },
  rejected: { label: "رد شده", variant: "destructive" },
}

export default function ApprovalPage() {
  const [filterUnit, setFilterUnit] = useState("all")
  const [filterStatus, setFilterStatus] = useState("pending")
  const [detailsOpen, setDetailsOpen] = useState(false)
  const [selectedStoppage, setSelectedStoppage] = useState<Stoppage | null>(null)
  const [rejectNote, setRejectNote] = useState("")
  const [actionDialogOpen, setActionDialogOpen] = useState(false)
  const [actionType, setActionType] = useState<"approve" | "reject">("approve")

  const filteredStoppages = mockStoppages.filter((s) => {
    if (filterUnit !== "all" && s.unit !== filterUnit) return false
    if (filterStatus === "pending" && s.status !== "pending_supervisor" && s.status !== "pending_inspector") return false
    if (filterStatus === "approved" && s.status !== "approved") return false
    if (filterStatus === "rejected" && s.status !== "rejected") return false
    return true
  })

  const openDetails = (stoppage: Stoppage) => {
    setSelectedStoppage(stoppage)
    setDetailsOpen(true)
  }

  const openAction = (stoppage: Stoppage, type: "approve" | "reject") => {
    setSelectedStoppage(stoppage)
    setActionType(type)
    setRejectNote("")
    setActionDialogOpen(true)
  }

  return (
    <AppLayout>
      <div className="p-6 space-y-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold text-foreground">تایید توقف‌ها</h1>
            <p className="text-sm text-muted-foreground mt-1">بررسی و تایید رکوردهای توقف ثبت شده</p>
          </div>
          <div className="flex items-center gap-3">
            <Select value={filterUnit} onValueChange={setFilterUnit}>
              <SelectTrigger className="w-36 bg-card text-card-foreground border-border">
                <SelectValue placeholder="واحد" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">همه واحدها</SelectItem>
                <SelectItem value="واحد تولید ۱">واحد تولید ۱</SelectItem>
                <SelectItem value="واحد تولید ۲">واحد تولید ۲</SelectItem>
                <SelectItem value="واحد تولید ۳">واحد تولید ۳</SelectItem>
              </SelectContent>
            </Select>
            <Select value={filterStatus} onValueChange={setFilterStatus}>
              <SelectTrigger className="w-36 bg-card text-card-foreground border-border">
                <SelectValue placeholder="وضعیت" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="pending">در انتظار تایید</SelectItem>
                <SelectItem value="approved">تایید شده</SelectItem>
                <SelectItem value="rejected">رد شده</SelectItem>
                <SelectItem value="all">همه</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Summary badges */}
        <div className="flex flex-wrap gap-3">
          <Badge variant="outline" className="text-sm py-1 px-3 border-border text-foreground">
            {'منتظر تایید: '}
            <span className="font-bold text-accent mr-1">
              {mockStoppages.filter(s => s.status === "pending_supervisor" || s.status === "pending_inspector").length}
            </span>
          </Badge>
          <Badge variant="outline" className="text-sm py-1 px-3 border-border text-foreground">
            {'تایید شده: '}
            <span className="font-bold text-success mr-1">
              {mockStoppages.filter(s => s.status === "approved").length}
            </span>
          </Badge>
          <Badge variant="outline" className="text-sm py-1 px-3 border-border text-foreground">
            {'رد شده: '}
            <span className="font-bold text-destructive mr-1">
              {mockStoppages.filter(s => s.status === "rejected").length}
            </span>
          </Badge>
        </div>

        <Card className="bg-card border-border">
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="border-border hover:bg-transparent">
                    <TableHead className="text-right text-muted-foreground">شناسه</TableHead>
                    <TableHead className="text-right text-muted-foreground">واحد</TableHead>
                    <TableHead className="text-right text-muted-foreground">ماشین</TableHead>
                    <TableHead className="text-right text-muted-foreground">نوع</TableHead>
                    <TableHead className="text-right text-muted-foreground">شروع</TableHead>
                    <TableHead className="text-right text-muted-foreground">ثبت‌کننده</TableHead>
                    <TableHead className="text-right text-muted-foreground">وضعیت</TableHead>
                    <TableHead className="text-right text-muted-foreground">عملیات</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredStoppages.map((stoppage) => {
                    const status = statusMap[stoppage.status]
                    const isPending = stoppage.status === "pending_supervisor" || stoppage.status === "pending_inspector"
                    return (
                      <TableRow key={stoppage.id} className="border-border">
                        <TableCell className="text-card-foreground text-sm font-mono">{stoppage.id}</TableCell>
                        <TableCell className="text-card-foreground text-sm">{stoppage.unit}</TableCell>
                        <TableCell className="text-card-foreground text-sm">{stoppage.machine}</TableCell>
                        <TableCell className="text-card-foreground text-sm">{stoppage.type}</TableCell>
                        <TableCell className="text-muted-foreground text-sm font-mono" dir="ltr">{stoppage.startTime}</TableCell>
                        <TableCell className="text-card-foreground text-sm">{stoppage.createdBy}</TableCell>
                        <TableCell>
                          <Badge variant={status.variant} className="text-xs whitespace-nowrap">
                            {status.label}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-1">
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => openDetails(stoppage)}
                              className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground hover:bg-secondary"
                            >
                              <Eye className="h-4 w-4" />
                              <span className="sr-only">مشاهده جزئیات</span>
                            </Button>
                            {isPending && (
                              <>
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  onClick={() => openAction(stoppage, "approve")}
                                  className="h-8 w-8 p-0 text-success hover:text-success hover:bg-success/10"
                                >
                                  <Check className="h-4 w-4" />
                                  <span className="sr-only">تایید</span>
                                </Button>
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  onClick={() => openAction(stoppage, "reject")}
                                  className="h-8 w-8 p-0 text-destructive hover:text-destructive hover:bg-destructive/10"
                                >
                                  <X className="h-4 w-4" />
                                  <span className="sr-only">رد</span>
                                </Button>
                              </>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* Details Dialog */}
        <Dialog open={detailsOpen} onOpenChange={setDetailsOpen}>
          <DialogContent className="max-w-lg bg-card text-card-foreground border-border">
            <DialogHeader>
              <DialogTitle className="text-card-foreground">جزئیات توقف {selectedStoppage?.id}</DialogTitle>
            </DialogHeader>
            {selectedStoppage && (
              <div className="space-y-3 text-sm">
                <div className="grid grid-cols-2 gap-3">
                  <div><span className="text-muted-foreground">واحد:</span> <span className="mr-1 text-card-foreground">{selectedStoppage.unit}</span></div>
                  <div><span className="text-muted-foreground">خط:</span> <span className="mr-1 text-card-foreground">{selectedStoppage.line}</span></div>
                  <div><span className="text-muted-foreground">ماشین:</span> <span className="mr-1 text-card-foreground">{selectedStoppage.machine}</span></div>
                  <div><span className="text-muted-foreground">شیفت:</span> <span className="mr-1 text-card-foreground">{selectedStoppage.shift}</span></div>
                  <div><span className="text-muted-foreground">شروع:</span> <span className="mr-1 text-card-foreground font-mono" dir="ltr">{selectedStoppage.startTime}</span></div>
                  <div><span className="text-muted-foreground">پایان:</span> <span className="mr-1 text-card-foreground font-mono" dir="ltr">{selectedStoppage.endTime}</span></div>
                  <div><span className="text-muted-foreground">نوع:</span> <span className="mr-1 text-card-foreground">{selectedStoppage.type}</span></div>
                  <div><span className="text-muted-foreground">علت:</span> <span className="mr-1 text-card-foreground">{selectedStoppage.cause}</span></div>
                </div>
                <div>
                  <span className="text-muted-foreground">توضیحات:</span>
                  <p className="mt-1 text-card-foreground">{selectedStoppage.description}</p>
                </div>
                {selectedStoppage.supervisorApproval && (
                  <div className="rounded-lg bg-secondary p-3">
                    <p className="text-xs text-muted-foreground mb-1">تایید سرپرست</p>
                    <p className="text-secondary-foreground">{selectedStoppage.supervisorApproval.by} - {selectedStoppage.supervisorApproval.at}</p>
                    {selectedStoppage.supervisorApproval.note && (
                      <p className="text-xs text-muted-foreground mt-1">{selectedStoppage.supervisorApproval.note}</p>
                    )}
                  </div>
                )}
                {selectedStoppage.inspectorApproval && (
                  <div className="rounded-lg bg-secondary p-3">
                    <p className="text-xs text-muted-foreground mb-1">تایید ناظر</p>
                    <p className="text-secondary-foreground">{selectedStoppage.inspectorApproval.by} - {selectedStoppage.inspectorApproval.at}</p>
                  </div>
                )}
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Action Dialog */}
        <Dialog open={actionDialogOpen} onOpenChange={setActionDialogOpen}>
          <DialogContent className="max-w-md bg-card text-card-foreground border-border">
            <DialogHeader>
              <DialogTitle className="text-card-foreground">
                {actionType === "approve" ? "تایید توقف" : "رد توقف"} {selectedStoppage?.id}
              </DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              <p className="text-sm text-muted-foreground">
                {actionType === "approve"
                  ? "آیا از تایید این رکورد توقف اطمینان دارید؟"
                  : "لطفا دلیل رد این رکورد توقف را وارد کنید."}
              </p>
              {actionType === "reject" && (
                <div className="space-y-2">
                  <Label className="text-card-foreground">دلیل رد</Label>
                  <Textarea
                    placeholder="دلیل رد را بنویسید..."
                    value={rejectNote}
                    onChange={(e) => setRejectNote(e.target.value)}
                    rows={3}
                    className="bg-secondary text-secondary-foreground placeholder:text-muted-foreground resize-none"
                  />
                </div>
              )}
            </div>
            <DialogFooter className="gap-2">
              <Button variant="outline" onClick={() => setActionDialogOpen(false)} className="border-border text-foreground">
                انصراف
              </Button>
              <Button
                onClick={() => setActionDialogOpen(false)}
                className={actionType === "approve"
                  ? "bg-success text-success-foreground hover:bg-success/90"
                  : "bg-destructive text-destructive-foreground hover:bg-destructive/90"
                }
              >
                {actionType === "approve" ? "تایید" : "رد کردن"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AppLayout>
  )
}
