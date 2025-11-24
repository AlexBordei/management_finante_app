# FinanceChat - Quick Reference Guide

**Quick lookup for common tasks and code snippets**

---

## 🚀 Quick Commands

### Backend (Laravel)

```bash
# Development
php artisan serve                          # Start dev server (http://localhost:8000)
php artisan queue:work redis              # Start queue worker
php artisan tinker                         # Interactive shell

# Database
php artisan migrate                        # Run migrations
php artisan migrate:fresh --seed          # Reset DB with seeds
php artisan db:seed                        # Run seeders only
php artisan migrate:rollback              # Rollback last migration

# Cache & Config
php artisan config:cache                   # Cache config (production)
php artisan route:cache                    # Cache routes (production)
php artisan view:cache                     # Cache views (production)
php artisan optimize:clear                 # Clear all caches

# Testing
php artisan test                           # Run all tests
php artisan test --filter=TransactionTest  # Run specific test

# Queue Management
php artisan queue:work --once             # Process one job
php artisan queue:failed                  # List failed jobs
php artisan queue:retry all               # Retry all failed
```

### Frontend (Next.js)

```bash
# Development
npm run dev                    # Start dev server (http://localhost:3000)
npm run build                  # Build for production
npm run start                  # Start production server
npm run lint                   # Run ESLint
npm run type-check            # TypeScript type checking

# Dependencies
npm install                    # Install all dependencies
npm install <package>         # Add new package
npm update                    # Update all packages
```

---

## 📁 File Locations Quick Reference

### Backend Files

```
app/Models/
  ├── User.php
  ├── Transaction.php
  ├── Category.php
  ├── Budget.php
  ├── Attachment.php
  ├── RecurringExpense.php
  └── AiConversation.php

app/Http/Controllers/
  ├── AuthController.php
  ├── TransactionController.php
  ├── CategoryController.php
  ├── BudgetController.php
  ├── UploadController.php
  ├── ChatController.php
  └── AnalyticsController.php

app/Services/
  ├── TransactionService.php
  ├── CategoryService.php
  ├── BudgetService.php
  ├── AnalyticsService.php
  ├── OCRService.php
  ├── ClaudeService.php
  └── ChatService.php

app/Jobs/
  ├── ProcessReceiptOCR.php
  └── ProcessBankStatement.php

routes/
  └── api.php              # All API routes
```

### Frontend Files

```
src/app/
  ├── (auth)/
  │   ├── login/page.tsx
  │   └── register/page.tsx
  ├── (dashboard)/
  │   ├── page.tsx                    # Dashboard
  │   ├── transactions/page.tsx
  │   ├── chat/page.tsx
  │   ├── budgets/page.tsx
  │   ├── analytics/page.tsx
  │   └── settings/page.tsx
  ├── layout.tsx
  └── providers.tsx

src/lib/
  ├── api/
  │   ├── client.ts
  │   ├── auth.ts
  │   ├── transactions.ts
  │   ├── categories.ts
  │   ├── budgets.ts
  │   ├── chat.ts
  │   ├── analytics.ts
  │   └── uploads.ts
  ├── hooks/
  │   ├── use-auth.ts
  │   ├── use-transactions.ts
  │   ├── use-categories.ts
  │   ├── use-budgets.ts
  │   └── use-chat.ts
  └── stores/
      ├── auth-store.ts
      └── ui-store.ts
```

---

## 🔑 Environment Variables

### Backend (.env)

```env
# Essential
APP_URL=http://localhost:8000
DB_CONNECTION=pgsql
DB_DATABASE=financechat
DB_USERNAME=your_username
DB_PASSWORD=your_password
REDIS_HOST=127.0.0.1
QUEUE_CONNECTION=redis
CLAUDE_API_KEY=sk-ant-api03-...

# Production
APP_ENV=production
APP_DEBUG=false
SANCTUM_STATEFUL_DOMAINS=app.yourdomain.com
SESSION_DOMAIN=.yourdomain.com
```

### Frontend (.env.local)

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

---

## 📊 Database Tables Quick View

```sql
users              # User accounts
categories         # Expense/income categories
transactions       # All financial transactions
budgets           # Monthly budgets
attachments       # Uploaded files
recurring_expenses # Detected recurring patterns
ai_conversations  # Chat history
personal_access_tokens # Auth tokens (Sanctum)
jobs              # Queue jobs
failed_jobs       # Failed queue jobs
```

---

## 🎯 Common Code Snippets

### Backend

#### Create Transaction
```php
use App\Services\TransactionService;

$transactionService = app(TransactionService::class);
$transaction = $transactionService->create(
    user: $user,
    data: [
        'amount' => 45.50,
        'type' => 'expense',
        'description' => 'Lunch',
        'category_id' => 3,
        'date' => now()->toDateString(),
    ]
);
```

#### Query Transactions
```php
// Get transactions for date range
$transactions = Transaction::where('user_id', $userId)
    ->whereBetween('date', [$startDate, $endDate])
    ->with('category')
    ->orderBy('date', 'desc')
    ->get();

// Get total by category
$totals = Transaction::where('user_id', $userId)
    ->where('type', 'expense')
    ->groupBy('category_id')
    ->select('category_id', DB::raw('SUM(amount) as total'))
    ->get();
```

#### Dispatch Queue Job
```php
use App\Jobs\ProcessReceiptOCR;

ProcessReceiptOCR::dispatch($attachment);
```

### Frontend

#### Make API Call
```typescript
import { apiClient } from '@/lib/api/client'

// GET
const response = await apiClient.get('/transactions')

// POST
const response = await apiClient.post('/transactions', {
  amount: 45.50,
  type: 'expense',
  description: 'Lunch',
  category_id: 3
})
```

#### Use React Query Hook
```typescript
import { useTransactions } from '@/lib/hooks/use-transactions'

function TransactionList() {
  const { data, isLoading } = useTransactions({
    type: 'expense',
    from_date: '2025-01-01',
    to_date: '2025-01-31'
  })

  if (isLoading) return <div>Loading...</div>

  return <div>{/* render transactions */}</div>
}
```

#### Use Zustand Store
```typescript
import { useAuthStore } from '@/lib/stores/auth-store'

function UserProfile() {
  const { user, logout } = useAuthStore()

  return (
    <div>
      <p>Welcome, {user?.name}</p>
      <button onClick={logout}>Logout</button>
    </div>
  )
}
```

---

## 🔌 API Endpoints Quick Reference

### Authentication
```
POST   /api/auth/register      # Register new user
POST   /api/auth/login         # Login
POST   /api/auth/logout        # Logout
GET    /api/auth/me            # Get current user
```

### Transactions
```
GET    /api/transactions       # List all (with filters)
POST   /api/transactions       # Create new
GET    /api/transactions/{id}  # Get single
PUT    /api/transactions/{id}  # Update
DELETE /api/transactions/{id}  # Delete
```

### Categories
```
GET    /api/categories         # List all
POST   /api/categories         # Create custom
PUT    /api/categories/{id}    # Update custom
DELETE /api/categories/{id}    # Delete custom
```

### Budgets
```
GET    /api/budgets            # List all
POST   /api/budgets            # Create new
PUT    /api/budgets/{id}       # Update
DELETE /api/budgets/{id}       # Delete
```

### Uploads
```
POST   /api/uploads/receipt           # Upload receipt
POST   /api/uploads/bank-statement    # Upload bank PDF
GET    /api/uploads/{id}/status       # Check status
```

### AI Chat
```
POST   /api/ai/chat                   # Send message
GET    /api/ai/conversations          # List conversations
DELETE /api/ai/conversations/{id}     # Delete conversation
```

### Analytics
```
GET    /api/analytics/overview                # Monthly overview
GET    /api/analytics/trends                  # Spending trends
POST   /api/analytics/detect-overspending     # Find overspending
POST   /api/analytics/detect-recurring        # Find recurring
POST   /api/analytics/optimization-plan       # Get recommendations
```

---

## 🎨 UI Components (shadcn/ui)

### Install Components
```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add input
npx shadcn-ui@latest add label
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add select
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add avatar
npx shadcn-ui@latest add dropdown-menu
npx shadcn-ui@latest add sheet
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add separator
```

### Usage Example
```typescript
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>
    <Button>Click Me</Button>
  </CardContent>
</Card>
```

---

## 🐛 Common Issues & Fixes

### Backend

**Issue**: CORS errors
```bash
# Fix: Update config/cors.php
'allowed_origins' => ['http://localhost:3000'],
'supports_credentials' => true,
```

**Issue**: Queue not processing
```bash
# Check Redis
redis-cli ping

# Restart queue worker
php artisan queue:restart
php artisan queue:work redis
```

**Issue**: Migrations fail
```bash
# Check database connection
php artisan migrate:status

# Reset and retry
php artisan migrate:fresh
```

### Frontend

**Issue**: API connection fails
```bash
# Check .env.local
NEXT_PUBLIC_API_URL=http://localhost:8000/api

# Restart dev server
npm run dev
```

**Issue**: Type errors
```bash
# Run type check
npm run type-check

# Check tsconfig.json paths
```

---

## 📦 Package Versions

### Backend
```json
{
  "laravel/framework": "^11.0",
  "laravel/sanctum": "^4.0",
  "thiagoalessio/tesseract_ocr": "^2.13"
}
```

### Frontend
```json
{
  "next": "^15.0.0",
  "react": "^19.0.0",
  "@tanstack/react-query": "^5.17.0",
  "zustand": "^4.4.7",
  "axios": "^1.6.5",
  "recharts": "^2.10.3",
  "zod": "^3.22.4"
}
```

---

## 🔍 Debugging Tips

### Backend
```php
// Use Laravel debugbar (dev only)
composer require barryvdh/laravel-debugbar --dev

// Log to file
Log::info('Transaction created', ['id' => $transaction->id]);

// Dump and die
dd($variable);

// Database query log
DB::enableQueryLog();
// ... queries ...
dd(DB::getQueryLog());
```

### Frontend
```typescript
// Console log with details
console.log('API Response:', { data, status })

// React Query DevTools (already included)
// Opens automatically in dev mode

// Type checking
npm run type-check

// Network tab in browser
// Check API requests/responses
```

---

## 📚 Documentation Files Index

1. **README.md** - Start here, project overview
2. **PROJECT_SUMMARY.md** - What's included, quick overview
3. **ARCHITECTURE.md** - System design, database, API specs
4. **DATABASE_MIGRATIONS.md** - All migrations
5. **LARAVEL_BACKEND_STRUCTURE.md** - Backend code
6. **LARAVEL_OCR_AI_IMPLEMENTATION.md** - OCR & AI code
7. **NEXTJS_FRONTEND_STRUCTURE.md** - Frontend code
8. **NEXTJS_COMPONENTS.md** - React components
9. **IMPLEMENTATION_GUIDE.md** - Setup & deployment
10. **WIREFRAMES_AND_EXAMPLES.md** - UI & workflows
11. **QUICK_REFERENCE.md** - This file

---

## 🚀 Quick Start Reminder

```bash
# Backend
composer create-project laravel/laravel financechat-backend
cd financechat-backend
composer require laravel/sanctum
php artisan migrate --seed
php artisan serve

# Frontend (new terminal)
npx create-next-app@latest financechat-frontend --typescript
cd financechat-frontend
npm install @tanstack/react-query zustand axios
npm run dev

# Visit: http://localhost:3000
```

---

## 💡 Pro Tips

1. **Use Laravel Tinker** for quick database queries
2. **Use React Query DevTools** to debug API calls
3. **Keep queue worker running** during development
4. **Use Postman Collections** to test API endpoints
5. **Git commit frequently** with meaningful messages
6. **Write tests as you code**, not after
7. **Use database transactions** for testing
8. **Cache aggressively** in production
9. **Monitor logs** regularly
10. **Document custom changes**

---

## 🎯 Next Steps After Setup

1. [ ] Test all API endpoints with Postman
2. [ ] Verify OCR processing with sample receipt
3. [ ] Test AI chat with various queries
4. [ ] Upload test bank statement
5. [ ] Create budgets and test tracking
6. [ ] Check analytics calculations
7. [ ] Test mobile responsiveness
8. [ ] Run security audit
9. [ ] Performance testing
10. [ ] Deploy to staging

---

**Keep this file handy for quick lookups during development!**

**Last Updated**: January 24, 2025
