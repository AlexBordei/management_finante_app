# Next.js Frontend Structure - FinanceChat

Complete frontend implementation with Next.js 15, React 19, TypeScript, and shadcn/ui.

---

## Directory Structure

```
financechat-frontend/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   └── register/
│   │   │       └── page.tsx
│   │   ├── (dashboard)/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx                    # Dashboard
│   │   │   ├── transactions/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/
│   │   │   │       └── page.tsx
│   │   │   ├── chat/
│   │   │   │   └── page.tsx
│   │   │   ├── budgets/
│   │   │   │   └── page.tsx
│   │   │   ├── analytics/
│   │   │   │   └── page.tsx
│   │   │   └── settings/
│   │   │       └── page.tsx
│   │   ├── layout.tsx                      # Root layout
│   │   ├── globals.css
│   │   └── providers.tsx
│   ├── components/
│   │   ├── ui/                             # shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── input.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── select.tsx
│   │   │   ├── badge.tsx
│   │   │   └── ...
│   │   ├── dashboard/
│   │   │   ├── stats-overview.tsx
│   │   │   ├── spending-chart.tsx
│   │   │   ├── category-breakdown.tsx
│   │   │   ├── recent-transactions.tsx
│   │   │   └── budget-progress.tsx
│   │   ├── transactions/
│   │   │   ├── transaction-list.tsx
│   │   │   ├── transaction-item.tsx
│   │   │   ├── add-transaction-dialog.tsx
│   │   │   └── transaction-filters.tsx
│   │   ├── chat/
│   │   │   ├── chat-interface.tsx
│   │   │   ├── message-list.tsx
│   │   │   ├── message-bubble.tsx
│   │   │   └── chat-input.tsx
│   │   ├── upload/
│   │   │   ├── receipt-upload.tsx
│   │   │   ├── bank-statement-upload.tsx
│   │   │   └── upload-status.tsx
│   │   ├── budgets/
│   │   │   ├── budget-list.tsx
│   │   │   ├── budget-card.tsx
│   │   │   └── add-budget-dialog.tsx
│   │   └── layout/
│   │       ├── sidebar.tsx
│   │       ├── header.tsx
│   │       └── mobile-nav.tsx
│   ├── lib/
│   │   ├── api/
│   │   │   ├── client.ts
│   │   │   ├── auth.ts
│   │   │   ├── transactions.ts
│   │   │   ├── categories.ts
│   │   │   ├── budgets.ts
│   │   │   ├── chat.ts
│   │   │   ├── analytics.ts
│   │   │   └── uploads.ts
│   │   ├── hooks/
│   │   │   ├── use-auth.ts
│   │   │   ├── use-transactions.ts
│   │   │   ├── use-categories.ts
│   │   │   ├── use-budgets.ts
│   │   │   └── use-chat.ts
│   │   ├── stores/
│   │   │   ├── auth-store.ts
│   │   │   └── ui-store.ts
│   │   ├── utils/
│   │   │   ├── format.ts
│   │   │   ├── date.ts
│   │   │   └── validation.ts
│   │   └── types/
│   │       ├── api.ts
│   │       ├── models.ts
│   │       └── components.ts
│   └── middleware.ts
├── public/
│   ├── icons/
│   └── images/
├── .env.local
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## 1. Package.json

**File**: `package.json`

```json
{
  "name": "financechat-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "@tanstack/react-query": "^5.17.0",
    "@tanstack/react-query-devtools": "^5.17.0",
    "zustand": "^4.4.7",
    "axios": "^1.6.5",
    "recharts": "^2.10.3",
    "date-fns": "^3.0.6",
    "zod": "^3.22.4",
    "react-hook-form": "^7.49.3",
    "@hookform/resolvers": "^3.3.4",
    "lucide-react": "^0.303.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0",
    "tailwindcss-animate": "^1.0.7"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "@types/react": "^18.2.46",
    "@types/react-dom": "^18.2.18",
    "typescript": "^5.3.3",
    "tailwindcss": "^3.4.1",
    "postcss": "^8.4.33",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.56.0",
    "eslint-config-next": "^15.0.0"
  }
}
```

---

## 2. TypeScript Configuration

**File**: `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

## 3. Tailwind Configuration

**File**: `tailwind.config.ts`

```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: ['class'],
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config
```

---

## 4. Global CSS

**File**: `src/app/globals.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
```

---

## 5. API Client

### Base Client

**File**: `src/lib/api/client.ts`

```typescript
import axios, { AxiosInstance, AxiosError } from 'axios'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api'

class APIClient {
  private client: AxiosInstance

  constructor() {
    this.client = axios.create({
      baseURL: API_URL,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      timeout: 30000,
    })

    // Request interceptor - add auth token
    this.client.interceptors.request.use(
      (config) => {
        const token = this.getToken()
        if (token) {
          config.headers.Authorization = `Bearer ${token}`
        }
        return config
      },
      (error) => Promise.reject(error)
    )

    // Response interceptor - handle errors
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        if (error.response?.status === 401) {
          this.clearToken()
          if (typeof window !== 'undefined') {
            window.location.href = '/login'
          }
        }
        return Promise.reject(error)
      }
    )
  }

  private getToken(): string | null {
    if (typeof window === 'undefined') return null
    return localStorage.getItem('auth_token')
  }

  private clearToken(): void {
    if (typeof window === 'undefined') return
    localStorage.removeItem('auth_token')
  }

  public setToken(token: string): void {
    if (typeof window === 'undefined') return
    localStorage.setItem('auth_token', token)
  }

  public get<T>(url: string, params?: any) {
    return this.client.get<T>(url, { params })
  }

  public post<T>(url: string, data?: any) {
    return this.client.post<T>(url, data)
  }

  public put<T>(url: string, data?: any) {
    return this.client.put<T>(url, data)
  }

  public delete<T>(url: string) {
    return this.client.delete<T>(url)
  }

  public upload<T>(url: string, formData: FormData) {
    return this.client.post<T>(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  }
}

export const apiClient = new APIClient()
```

---

### Auth API

**File**: `src/lib/api/auth.ts`

```typescript
import { apiClient } from './client'

export interface LoginRequest {
  email: string
  password: string
}

export interface RegisterRequest {
  name: string
  email: string
  password: string
  password_confirmation: string
}

export interface AuthResponse {
  user: {
    id: number
    name: string
    email: string
  }
  token: string
}

export const authAPI = {
  login: async (data: LoginRequest): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>('/auth/login', data)
    apiClient.setToken(response.data.token)
    return response.data
  },

  register: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>('/auth/register', data)
    apiClient.setToken(response.data.token)
    return response.data
  },

  logout: async (): Promise<void> => {
    await apiClient.post('/auth/logout')
    localStorage.removeItem('auth_token')
  },

  me: async () => {
    const response = await apiClient.get('/auth/me')
    return response.data
  },
}
```

---

### Transactions API

**File**: `src/lib/api/transactions.ts`

```typescript
import { apiClient } from './client'
import { Transaction, PaginatedResponse } from '../types/models'

export interface TransactionFilters {
  type?: 'expense' | 'income'
  category_id?: number
  from_date?: string
  to_date?: string
  page?: number
  per_page?: number
}

export interface CreateTransactionRequest {
  amount: number
  type: 'expense' | 'income'
  description?: string
  date?: string
  category_id: number
  source?: string
}

export const transactionsAPI = {
  list: async (filters?: TransactionFilters): Promise<PaginatedResponse<Transaction>> => {
    const response = await apiClient.get<PaginatedResponse<Transaction>>('/transactions', filters)
    return response.data
  },

  get: async (id: number): Promise<{ data: Transaction }> => {
    const response = await apiClient.get<{ data: Transaction }>(`/transactions/${id}`)
    return response.data
  },

  create: async (data: CreateTransactionRequest): Promise<{ data: Transaction }> => {
    const response = await apiClient.post<{ data: Transaction }>('/transactions', data)
    return response.data
  },

  update: async (id: number, data: Partial<CreateTransactionRequest>): Promise<{ data: Transaction }> => {
    const response = await apiClient.put<{ data: Transaction }>(`/transactions/${id}`, data)
    return response.data
  },

  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`/transactions/${id}`)
  },
}
```

---

### Chat API

**File**: `src/lib/api/chat.ts`

```typescript
import { apiClient } from './client'

export interface ChatMessageRequest {
  message: string
  conversation_id?: number
}

export interface ChatMessageResponse {
  conversation_id: number
  response: string
  tool_calls?: Array<{
    tool: string
    parameters: Record<string, any>
  }>
}

export const chatAPI = {
  sendMessage: async (data: ChatMessageRequest): Promise<ChatMessageResponse> => {
    const response = await apiClient.post<ChatMessageResponse>('/ai/chat', data)
    return response.data
  },

  listConversations: async () => {
    const response = await apiClient.get('/ai/conversations')
    return response.data
  },

  deleteConversation: async (id: number): Promise<void> => {
    await apiClient.delete(`/ai/conversations/${id}`)
  },
}
```

---

## 6. Type Definitions

**File**: `src/lib/types/models.ts`

```typescript
export interface User {
  id: number
  name: string
  email: string
  created_at: string
}

export interface Category {
  id: number
  name: string
  type: 'expense' | 'income'
  is_predefined: boolean
  icon?: string
  color?: string
}

export interface Transaction {
  id: number
  amount: string
  type: 'expense' | 'income'
  description?: string
  date: string
  category?: Category
  source: string
  metadata?: Record<string, any>
  attachments?: Attachment[]
  created_at: string
  updated_at: string
}

export interface Budget {
  id: number
  category: Category
  month: number
  year: number
  amount: string
  spent: string
  remaining: string
  percentage: number
}

export interface Attachment {
  id: number
  file_path: string
  file_type: string
  ocr_status: 'pending' | 'processing' | 'completed' | 'failed'
}

export interface PaginatedResponse<T> {
  data: T[]
  meta: {
    current_page: number
    total: number
    per_page: number
  }
}

export interface MonthSummary {
  period: {
    month: number
    year: number
  }
  summary: {
    total_income: string
    total_expenses: string
    net: string
    savings_rate: number
  }
  expenses_by_category: Array<{
    category: string
    amount: string
    percentage: number
  }>
}
```

---

## 7. React Query Hooks

### useTransactions

**File**: `src/lib/hooks/use-transactions.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { transactionsAPI, TransactionFilters, CreateTransactionRequest } from '../api/transactions'
import { toast } from 'sonner'

export const useTransactions = (filters?: TransactionFilters) => {
  return useQuery({
    queryKey: ['transactions', filters],
    queryFn: () => transactionsAPI.list(filters),
  })
}

export const useTransaction = (id: number) => {
  return useQuery({
    queryKey: ['transaction', id],
    queryFn: () => transactionsAPI.get(id),
    enabled: !!id,
  })
}

export const useCreateTransaction = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: CreateTransactionRequest) => transactionsAPI.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] })
      toast.success('Transaction created successfully')
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to create transaction')
    },
  })
}

export const useUpdateTransaction = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<CreateTransactionRequest> }) =>
      transactionsAPI.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] })
      toast.success('Transaction updated successfully')
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to update transaction')
    },
  })
}

export const useDeleteTransaction = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => transactionsAPI.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] })
      toast.success('Transaction deleted successfully')
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to delete transaction')
    },
  })
}
```

---

## 8. Zustand Store

**File**: `src/lib/stores/auth-store.ts`

```typescript
import { create } from 'zustand'
import { User } from '../types/models'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  setUser: (user: User) => void
  setToken: (token: string) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: typeof window !== 'undefined' ? localStorage.getItem('auth_token') : null,
  isAuthenticated: false,

  setUser: (user) => set({ user, isAuthenticated: true }),

  setToken: (token) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_token', token)
    }
    set({ token, isAuthenticated: true })
  },

  logout: () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth_token')
    }
    set({ user: null, token: null, isAuthenticated: false })
  },
}))
```

---

**Continue with component implementations in next file...**

