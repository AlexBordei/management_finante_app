# FinanceChat - Quick Start Guide

## 🚀 Backend Setup (5 minutes)

### Step 1: Configure Environment

```bash
cd financechat-backend

# Edit .env file with your credentials
nano .env
```

Update these values:
```env
DB_DATABASE=financechat
DB_USERNAME=your_postgres_username
DB_PASSWORD=your_postgres_password

# Get your Claude API key from: https://console.anthropic.com/
CLAUDE_API_KEY=sk-ant-xxxx...
```

### Step 2: Create Database

```bash
# Create PostgreSQL database
createdb financechat

# Or using psql:
psql -U postgres -c "CREATE DATABASE financechat;"
```

### Step 3: Run Migrations

```bash
# Install dependencies (if not already done)
composer install

# Run migrations and seed categories
php artisan migrate:fresh --seed

# You should see:
# ✅ Created 7 tables
# ✅ Seeded 18 categories
```

### Step 4: Create Storage Link

```bash
php artisan storage:link
```

### Step 5: Start Server

```bash
# Terminal 1: Laravel server
php artisan serve

# Terminal 2: Queue worker (optional, for OCR jobs later)
php artisan queue:work
```

Your backend is now running at: **http://localhost:8000**

---

## 🧪 Test the Backend

### Option 1: Use the Test Script

```bash
# Make sure server is running, then:
./test-api.sh
```

This will automatically test:
- ✅ User registration
- ✅ User login
- ✅ Categories listing
- ✅ Transaction creation
- ✅ Budget creation
- ✅ Analytics
- ✅ AI chat (if API key configured)

### Option 2: Manual Testing with cURL

#### 1. Register a User

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

Save the `token` from the response!

#### 2. Get Categories

```bash
curl -X GET http://localhost:8000/api/categories \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

You should see 18 categories.

#### 3. Create a Transaction

```bash
curl -X POST http://localhost:8000/api/transactions \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": 1,
    "amount": 50.00,
    "type": "expense",
    "date": "2024-11-24",
    "description": "Grocery shopping"
  }'
```

#### 4. Chat with AI

```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Add a $30 expense for coffee today"
  }'
```

---

## 📊 Available Endpoints

### Authentication
- `POST /api/auth/register` - Register
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Current user
- `POST /api/auth/logout` - Logout

### Transactions
- `GET /api/transactions` - List (with filters)
- `POST /api/transactions` - Create
- `GET /api/transactions/{id}` - Get one
- `PUT /api/transactions/{id}` - Update
- `DELETE /api/transactions/{id}` - Delete
- `GET /api/transactions/stats/summary` - Monthly stats

### Categories
- `GET /api/categories` - List all
- `POST /api/categories` - Create
- `PUT /api/categories/{id}` - Update
- `DELETE /api/categories/{id}` - Delete

### Budgets
- `GET /api/budgets` - List all
- `POST /api/budgets` - Create
- `PUT /api/budgets/{id}` - Update
- `DELETE /api/budgets/{id}` - Delete
- `GET /api/budgets/stats/progress` - Progress

### AI Chat
- `POST /api/chat` - Send message
- `GET /api/chat/conversations` - List conversations
- `GET /api/chat/conversations/{id}` - Get conversation
- `DELETE /api/chat/conversations/{id}` - Delete

### Analytics
- `GET /api/analytics/overview` - Overview
- `GET /api/analytics/overspending` - Detect overspending
- `GET /api/analytics/recurring-expenses` - Find recurring
- `GET /api/analytics/optimization-plan` - Get savings plan
- `GET /api/analytics/category-breakdown` - Category breakdown
- `GET /api/analytics/trends` - Monthly trends

---

## 🔧 Troubleshooting

### Database Connection Error

```bash
# Check PostgreSQL is running
pg_isready

# Check database exists
psql -l | grep financechat

# If not, create it
createdb financechat
```

### Migration Errors

```bash
# Reset database
php artisan migrate:fresh --seed

# If issues persist, check .env file
cat .env | grep DB_
```

### API Returns 401 Unauthorized

- Check you're including the Authorization header
- Verify token is valid (not expired)
- Try logging in again to get a new token

### AI Chat Returns Error

- Check CLAUDE_API_KEY is set in .env
- Verify API key is valid at https://console.anthropic.com/
- Check you have API credits

### Routes Not Found

```bash
# Clear route cache
php artisan route:clear

# Check routes are loaded
php artisan route:list
```

---

## 🎯 Next Steps

### 1. Backend Complete ✅
- All API endpoints working
- Authentication implemented
- AI integration ready
- Analytics engine built

### 2. Frontend Development (Next)

Create the Next.js frontend:

```bash
cd ..  # Go back to personalDB directory

# Create Next.js app
npx create-next-app@latest financechat-frontend \
  --typescript \
  --tailwind \
  --app \
  --import-alias "@/*"

cd financechat-frontend

# Install dependencies
npm install @tanstack/react-query zustand axios recharts zod react-hook-form @hookform/resolvers

# Install shadcn/ui
npx shadcn-ui@latest init

# Add components
npx shadcn-ui@latest add button card input dialog select textarea label form table badge

# Create .env.local
echo "NEXT_PUBLIC_API_URL=http://localhost:8000/api" > .env.local

# Start dev server
npm run dev
```

### 3. Implementation Order

1. **API Client** (1 hour)
   - Create axios instance
   - Add auth interceptor
   - Define TypeScript types

2. **Authentication** (2 hours)
   - Login page
   - Register page
   - Auth context/store
   - Protected routes

3. **Dashboard** (3 hours)
   - Overview cards
   - Recent transactions
   - Budget progress
   - Category chart

4. **Transactions** (3 hours)
   - Transaction list
   - Add/Edit form
   - Filters
   - Pagination

5. **AI Chat** (2 hours)
   - Chat interface
   - Message display
   - Input with send
   - Conversation history

6. **Analytics** (2 hours)
   - Overspending alerts
   - Recurring expenses
   - Optimization plan
   - Trend charts

---

## 📚 Documentation

- [README_BACKEND.md](financechat-backend/README_BACKEND.md) - Complete API docs
- [BACKEND_IMPLEMENTATION_SUMMARY.md](BACKEND_IMPLEMENTATION_SUMMARY.md) - Implementation details
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Overall project status

---

## ✨ Features Available

### ✅ Working Now
- User registration/login
- Transaction CRUD
- Category management
- Budget tracking
- AI chat with Claude
- Financial analytics
- Overspending detection
- Recurring expense detection
- Optimization recommendations

### ⏳ Coming Soon (Optional)
- OCR receipt scanning
- Bank statement import
- Mobile app
- Email notifications
- Recurring transaction automation

---

## 🎉 You're Ready!

The backend is fully functional and ready for testing or frontend development.

**Estimated time to working MVP**:
- Backend: ✅ Complete
- Frontend: ~10-15 hours of development

Good luck! 🚀
