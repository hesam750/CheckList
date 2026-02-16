import type { Metadata, Viewport } from 'next'
import { Geist, Geist_Mono } from 'next/font/google'

import './globals.css'

const _geist = Geist({ subsets: ['latin'] })
const _geistMono = Geist_Mono({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'سامانه مدیریت توقفات کارخانه',
  description: 'سامانه ثبت، پیگیری و تحلیل توقفات خطوط تولید',
}

export const viewport: Viewport = {
  themeColor: '#1a2332',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="fa" dir="rtl" className="dark">
      <body className="font-sans antialiased">{children}</body>
    </html>
  )
}
