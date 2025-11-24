# Next.js Components - FinanceChat

Complete React component implementations for all pages and features.

---

## 1. Root Layout & Providers

### Root Layout

**File**: `src/app/layout.tsx`

```typescript
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'FinanceChat - AI-Powered Finance Manager',
  description: 'Manage your finances with AI assistance',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

---

### Providers

**File**: `src/app/providers.tsx`

```typescript
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState } from 'react'
import { Toaster } from 'sonner'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000, // 1 minute
            refetchOnWindowFocus: false,
          },
        },
      })
  )

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <Toaster position="top-right" richColors />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

---

## 2. Authentication Pages

### Login Page

**File**: `src/app/(auth)/login/page.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { authAPI } from '@/lib/api/auth'
import { useAuthStore } from '@/lib/stores/auth-store'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { toast } from 'sonner'

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
})

type LoginForm = z.infer<typeof loginSchema>

export default function LoginPage() {
  const router = useRouter()
  const { setUser, setToken } = useAuthStore()
  const [isLoading, setIsLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginForm) => {
    setIsLoading(true)
    try {
      const response = await authAPI.login(data)
      setUser(response.user)
      setToken(response.token)
      toast.success('Welcome back!')
      router.push('/dashboard')
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Login failed')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">Welcome to FinanceChat</CardTitle>
          <CardDescription className="text-center">
            Sign in to your account to continue
          </CardDescription>
        </CardHeader>
        <form onSubmit={handleSubmit(onSubmit)}>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="you@example.com"
                {...register('email')}
                disabled={isLoading}
              />
              {errors.email && (
                <p className="text-sm text-red-500">{errors.email.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                {...register('password')}
                disabled={isLoading}
              />
              {errors.password && (
                <p className="text-sm text-red-500">{errors.password.message}</p>
              )}
            </div>
          </CardContent>
          <CardFooter className="flex flex-col space-y-4">
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? 'Signing in...' : 'Sign In'}
            </Button>
            <p className="text-sm text-center text-muted-foreground">
              Don't have an account?{' '}
              <Link href="/register" className="text-primary hover:underline">
                Sign up
              </Link>
            </p>
          </CardFooter>
        </form>
      </Card>
    </div>
  )
}
```

---

## 3. Dashboard Layout

**File**: `src/app/(dashboard)/layout.tsx`

```typescript
'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/stores/auth-store'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter()
  const { isAuthenticated } = useAuthStore()

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/login')
    }
  }, [isAuthenticated, router])

  if (!isAuthenticated) {
    return null
  }

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-y-auto bg-gray-50 p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
```

---

### Sidebar Component

**File**: `src/components/layout/sidebar.tsx`

```typescript
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import {
  LayoutDashboard,
  CreditCard,
  MessageSquare,
  PieChart,
  Wallet,
  Settings,
  LogOut,
} from 'lucide-react'
import { useAuthStore } from '@/lib/stores/auth-store'
import { authAPI } from '@/lib/api/auth'
import { useRouter } from 'next/navigation'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Transactions', href: '/transactions', icon: CreditCard },
  { name: 'AI Chat', href: '/chat', icon: MessageSquare },
  { name: 'Budgets', href: '/budgets', icon: Wallet },
  { name: 'Analytics', href: '/analytics', icon: PieChart },
  { name: 'Settings', href: '/settings', icon: Settings },
]

export function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const { logout } = useAuthStore()

  const handleLogout = async () => {
    try {
      await authAPI.logout()
      logout()
      router.push('/login')
    } catch (error) {
      console.error('Logout failed:', error)
    }
  }

  return (
    <div className="hidden md:flex md:w-64 md:flex-col bg-gray-900">
      <div className="flex flex-col flex-1 min-h-0">
        <div className="flex items-center h-16 flex-shrink-0 px-4 bg-gray-900">
          <h1 className="text-xl font-bold text-white">FinanceChat</h1>
        </div>
        <div className="flex-1 flex flex-col overflow-y-auto">
          <nav className="flex-1 px-2 py-4 space-y-1">
            {navigation.map((item) => {
              const isActive = pathname.startsWith(item.href)
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={cn(
                    'group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors',
                    isActive
                      ? 'bg-gray-800 text-white'
                      : 'text-gray-300 hover:bg-gray-700 hover:text-white'
                  )}
                >
                  <item.icon
                    className={cn(
                      'mr-3 flex-shrink-0 h-6 w-6',
                      isActive ? 'text-white' : 'text-gray-400 group-hover:text-white'
                    )}
                  />
                  {item.name}
                </Link>
              )
            })}
          </nav>
        </div>
        <div className="flex-shrink-0 flex border-t border-gray-800 p-4">
          <button
            onClick={handleLogout}
            className="flex-1 group flex items-center text-sm font-medium text-gray-300 hover:text-white transition-colors"
          >
            <LogOut className="mr-3 h-6 w-6 text-gray-400 group-hover:text-white" />
            Logout
          </button>
        </div>
      </div>
    </div>
  )
}
```

---

### Header Component

**File**: `src/components/layout/header.tsx`

```typescript
'use client'

import { useAuthStore } from '@/lib/stores/auth-store'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'

export function Header() {
  const { user } = useAuthStore()

  const initials = user?.name
    ?.split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase() || 'U'

  return (
    <header className="h-16 flex items-center justify-between px-6 bg-white border-b border-gray-200">
      <div className="flex items-center">
        <h2 className="text-xl font-semibold text-gray-800">
          Welcome back, {user?.name?.split(' ')[0] || 'User'}
        </h2>
      </div>
      <div className="flex items-center space-x-4">
        <Avatar>
          <AvatarFallback>{initials}</AvatarFallback>
        </Avatar>
      </div>
    </header>
  )
}
```

---

## 4. Dashboard Page

**File**: `src/app/(dashboard)/page.tsx`

```typescript
'use client'

import { StatsOverview } from '@/components/dashboard/stats-overview'
import { SpendingChart } from '@/components/dashboard/spending-chart'
import { CategoryBreakdown } from '@/components/dashboard/category-breakdown'
import { RecentTransactions } from '@/components/dashboard/recent-transactions'
import { BudgetProgress } from '@/components/dashboard/budget-progress'

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">
          Overview of your financial activity this month
        </p>
      </div>

      <StatsOverview />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <SpendingChart />
        <CategoryBreakdown />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <RecentTransactions />
        <BudgetProgress />
      </div>
    </div>
  )
}
```

---

### Stats Overview Component

**File**: `src/components/dashboard/stats-overview.tsx`

```typescript
'use client'

import { useQuery } from '@tanstack/react-query'
import { analyticsAPI } from '@/lib/api/analytics'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { TrendingUp, TrendingDown, DollarSign, Wallet } from 'lucide-react'

export function StatsOverview() {
  const currentDate = new Date()
  const { data, isLoading } = useQuery({
    queryKey: ['overview', currentDate.getMonth() + 1, currentDate.getFullYear()],
    queryFn: () =>
      analyticsAPI.getOverview({
        month: currentDate.getMonth() + 1,
        year: currentDate.getFullYear(),
      }),
  })

  const stats = [
    {
      title: 'Total Income',
      value: data?.summary.total_income || '0.00',
      icon: TrendingUp,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      title: 'Total Expenses',
      value: data?.summary.total_expenses || '0.00',
      icon: TrendingDown,
      color: 'text-red-600',
      bgColor: 'bg-red-100',
    },
    {
      title: 'Net Balance',
      value: data?.summary.net || '0.00',
      icon: DollarSign,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      title: 'Savings Rate',
      value: `${data?.summary.savings_rate || 0}%`,
      icon: Wallet,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
  ]

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[1, 2, 3, 4].map((i) => (
          <Card key={i}>
            <CardContent className="p-6">
              <div className="animate-pulse space-y-2">
                <div className="h-4 bg-gray-200 rounded w-20"></div>
                <div className="h-8 bg-gray-200 rounded w-32"></div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat) => (
        <Card key={stat.title}>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  ${stat.value}
                </p>
              </div>
              <div className={`${stat.bgColor} p-3 rounded-full`}>
                <stat.icon className={`h-6 w-6 ${stat.color}`} />
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
```

---

## 5. Transactions Page

**File**: `src/app/(dashboard)/transactions/page.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useTransactions } from '@/lib/hooks/use-transactions'
import { TransactionList } from '@/components/transactions/transaction-list'
import { TransactionFilters } from '@/components/transactions/transaction-filters'
import { AddTransactionDialog } from '@/components/transactions/add-transaction-dialog'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

export default function TransactionsPage() {
  const [filters, setFilters] = useState({})
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)

  const { data, isLoading } = useTransactions(filters)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Transactions</h1>
          <p className="text-gray-600 mt-1">View and manage your transactions</p>
        </div>
        <Button onClick={() => setIsAddDialogOpen(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Add Transaction
        </Button>
      </div>

      <TransactionFilters onFilterChange={setFilters} />

      <TransactionList transactions={data?.data || []} isLoading={isLoading} />

      <AddTransactionDialog
        open={isAddDialogOpen}
        onOpenChange={setIsAddDialogOpen}
      />
    </div>
  )
}
```

---

### Transaction List Component

**File**: `src/components/transactions/transaction-list.tsx`

```typescript
'use client'

import { Transaction } from '@/lib/types/models'
import { TransactionItem } from './transaction-item'
import { Card, CardContent } from '@/components/ui/card'

interface TransactionListProps {
  transactions: Transaction[]
  isLoading: boolean
}

export function TransactionList({ transactions, isLoading }: TransactionListProps) {
  if (isLoading) {
    return (
      <Card>
        <CardContent className="p-6">
          <div className="space-y-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <div key={i} className="animate-pulse flex items-center space-x-4">
                <div className="h-12 w-12 bg-gray-200 rounded-full"></div>
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-gray-200 rounded w-1/4"></div>
                  <div className="h-3 bg-gray-200 rounded w-1/3"></div>
                </div>
                <div className="h-6 bg-gray-200 rounded w-20"></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  if (transactions.length === 0) {
    return (
      <Card>
        <CardContent className="p-12 text-center">
          <p className="text-gray-500">No transactions found</p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardContent className="p-6">
        <div className="space-y-4">
          {transactions.map((transaction) => (
            <TransactionItem key={transaction.id} transaction={transaction} />
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
```

---

## 6. AI Chat Page

**File**: `src/app/(dashboard)/chat/page.tsx`

```typescript
'use client'

import { ChatInterface } from '@/components/chat/chat-interface'

export default function ChatPage() {
  return (
    <div className="h-[calc(100vh-8rem)]">
      <div className="mb-4">
        <h1 className="text-3xl font-bold text-gray-900">AI Assistant</h1>
        <p className="text-gray-600 mt-1">
          Ask questions about your finances or add transactions naturally
        </p>
      </div>
      <ChatInterface />
    </div>
  )
}
```

---

### Chat Interface Component

**File**: `src/components/chat/chat-interface.tsx`

```typescript
'use client'

import { useState, useRef, useEffect } from 'react'
import { useMutation } from '@tanstack/react-query'
import { chatAPI } from '@/lib/api/chat'
import { Card } from '@/components/ui/card'
import { MessageList } from './message-list'
import { ChatInput } from './chat-input'

interface Message {
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

export function ChatInterface() {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'assistant',
      content: "Hello! I'm your finance assistant. How can I help you today? You can ask about your spending, add transactions, or get financial insights.",
      timestamp: new Date(),
    },
  ])
  const [conversationId, setConversationId] = useState<number | undefined>()
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const sendMessageMutation = useMutation({
    mutationFn: chatAPI.sendMessage,
    onSuccess: (data) => {
      setConversationId(data.conversation_id)
      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          content: data.response,
          timestamp: new Date(),
        },
      ])
    },
  })

  const handleSendMessage = (content: string) => {
    setMessages((prev) => [
      ...prev,
      {
        role: 'user',
        content,
        timestamp: new Date(),
      },
    ])

    sendMessageMutation.mutate({
      message: content,
      conversation_id: conversationId,
    })
  }

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  return (
    <Card className="h-full flex flex-col">
      <div className="flex-1 overflow-y-auto p-6">
        <MessageList messages={messages} />
        <div ref={messagesEndRef} />
      </div>
      <div className="border-t p-4">
        <ChatInput
          onSend={handleSendMessage}
          isLoading={sendMessageMutation.isPending}
        />
      </div>
    </Card>
  )
}
```

---

**This covers the main structure. Additional components like forms, charts, and utilities would follow similar patterns.**

