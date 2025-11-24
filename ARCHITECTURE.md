# FinanceChat - System Architecture Documentation

## Table of Contents
1. [Overview](#overview)
2. [Technology Stack](#technology-stack)
3. [System Architecture](#system-architecture)
4. [Database Schema](#database-schema)
5. [API Specifications](#api-specifications)
6. [AI Integration](#ai-integration)
7. [Security](#security)
8. [Deployment](#deployment)

---

## 1. Overview

FinanceChat is a personal finance management application that combines traditional dashboard functionality with AI-powered chat interactions. Users can manage their finances through natural conversation while also having access to visual analytics and reports.

### Core Features
- **Manual Transaction Entry**: Add expenses and incomes with categories
- **AI Chat Interface**: Natural language interaction for all operations
- **OCR Processing**: Upload receipts/invoices for automatic data extraction
- **Bank Statement Import**: Upload monthly PDF statements for bulk transaction import
- **Budget Management**: Set and track monthly budgets per category
- **AI Analytics**:
  - Overspending detection
  - Month-over-month comparisons
  - Recurring expense identification
  - Personalized optimization recommendations
- **Visual Dashboard**: Charts and graphs for financial insights

---

## 2. Technology Stack

### Frontend
- **Framework**: Next.js 15 (App Router)
- **UI Library**: React 19
- **Language**: TypeScript
- **Styling**: TailwindCSS
- **Component Library**: shadcn/ui
- **Charts**: Recharts
- **State Management**: Zustand (UI state)
- **Data Fetching**: TanStack Query (React Query)

### Backend
- **Framework**: Laravel 11
- **Language**: PHP 8.3+
- **Authentication**: Laravel Sanctum
- **Database**: PostgreSQL 15+
- **Queue System**: Redis
- **Testing**: Pest PHP
- **OCR Engine**: Tesseract OCR

### AI Processing
- **LLM Provider**: Anthropic Claude API (Claude 3.5 Sonnet)
- **Use Cases**:
  - Natural language understanding
  - Transaction classification
  - Financial analysis
  - Receipt/statement parsing
  - Optimization recommendations

---

## 3. System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  Next.js App (Browser - Desktop & Mobile Responsive)        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐       │
│  │  Dashboard   │  │  AI Chat     │  │  Import     │       │
│  │  Page        │  │  Page        │  │  Wizard     │       │
│  └──────────────┘  └──────────────┘  └─────────────┘       │
└─────────────────────────┬───────────────────────────────────┘
                          │ REST API (JSON)
                          │ Authentication: Bearer Token
┌─────────────────────────┴───────────────────────────────────┐
│                     API LAYER                                │
│  Laravel 11 Application                                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  HTTP Layer                                         │    │
│  │  Routes → Middleware → Controllers                  │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Business Logic Layer                               │    │
│  │  Services → Repositories → Models                   │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Background Processing                              │    │
│  │  Queue Jobs (OCR, AI Analysis, PDF Parsing)        │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────┬──────────────────────┬────────────────────┘
                  │                      │
        ┌─────────┴─────────┐   ┌────────┴─────────┐
        │   PostgreSQL      │   │  Redis Queue     │
        │   Database        │   │  + Cache         │
        └───────────────────┘   └──────────────────┘
                  │
        ┌─────────┴─────────┐
        │  External APIs    │
        │  - Claude API     │
        │  - Tesseract OCR  │
        └───────────────────┘
```

### Request Flow

#### 1. Standard API Request
```
User → Next.js → API Client → Laravel Controller → Service → Repository → Database
                                        ↓
                                    Response
```

#### 2. AI Chat Request
```
User → Chat UI → API Client → ChatController → ClaudeService
                                                     ↓
                                            Tool Call Detection
                                                     ↓
                              TransactionService/AnalysisService
                                                     ↓
                                                 Database
                                                     ↓
                                            Format Response
                                                     ↓
                                            Claude API
                                                     ↓
                                        Natural Language Response
```

#### 3. OCR Upload Request
```
User → Upload Component → API Client → UploadController
                                            ↓
                                    Store File + Dispatch Job
                                            ↓
                                        Queue (Redis)
                                            ↓
                                        OCR Job Worker
                                            ↓
                                    Tesseract Processing
                                            ↓
                                        Claude API (Parse)
                                            ↓
                                    Create Transaction
                                            ↓
                                    Update Job Status
                                            ↓
                                    WebSocket Notification (optional)
```

---

## 4. Database Schema

### Tables

#### users
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### categories
```sql
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('expense', 'income')),
    is_predefined BOOLEAN DEFAULT FALSE,
    icon VARCHAR(50),
    color VARCHAR(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, name, type)
);

CREATE INDEX idx_categories_user_type ON categories(user_id, type);
```

**Predefined Categories** (seeded on user creation):
- **Expenses**: Food & Dining, Transportation, Housing, Utilities, Healthcare, Entertainment, Shopping, Education, Insurance, Personal Care, Travel, Subscriptions, Other
- **Income**: Salary, Freelance, Investment, Gift, Other

#### transactions
```sql
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('expense', 'income')),
    description TEXT,
    date DATE NOT NULL,
    source VARCHAR(50) DEFAULT 'manual', -- manual, ocr, bank_import, ai_chat
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_user_date ON transactions(user_id, date DESC);
CREATE INDEX idx_transactions_user_category ON transactions(user_id, category_id);
CREATE INDEX idx_transactions_source ON transactions(source);
```

#### attachments
```sql
CREATE TABLE attachments (
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT REFERENCES transactions(id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL, -- receipt, invoice, statement
    file_size INTEGER,
    ocr_status VARCHAR(20) DEFAULT 'pending', -- pending, processing, completed, failed
    ocr_text JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attachments_transaction ON attachments(transaction_id);
CREATE INDEX idx_attachments_ocr_status ON attachments(ocr_status);
```

#### budgets
```sql
CREATE TABLE budgets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    year INTEGER NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, category_id, month, year)
);

CREATE INDEX idx_budgets_user_period ON budgets(user_id, year, month);
```

#### recurring_expenses
```sql
CREATE TABLE recurring_expenses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL,
    frequency VARCHAR(20) DEFAULT 'monthly', -- monthly, weekly, yearly
    description TEXT,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confidence_score DECIMAL(3, 2), -- 0.00 to 1.00
    is_confirmed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recurring_user ON recurring_expenses(user_id);
```

#### ai_conversations
```sql
CREATE TABLE ai_conversations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    messages JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_user ON ai_conversations(user_id);
```

---

## 5. API Specifications

### Base URL
```
Production: https://api.financechat.com/api
Development: http://localhost:8000/api
```

### Authentication
All endpoints (except `/auth/login` and `/auth/register`) require authentication via Laravel Sanctum.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### API Endpoints

#### Authentication

##### POST /auth/register
Register a new user.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "password_confirmation": "SecurePass123!"
}
```

**Response (201):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-01-15T10:30:00Z"
  },
  "token": "1|abc123def456..."
}
```

##### POST /auth/login
Authenticate user.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "token": "2|xyz789uvw456..."
}
```

##### POST /auth/logout
Revoke current token.

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

#### Transactions

##### GET /transactions
List all transactions with filtering.

**Query Parameters:**
- `type`: expense | income
- `category_id`: integer
- `from_date`: YYYY-MM-DD
- `to_date`: YYYY-MM-DD
- `page`: integer (default: 1)
- `per_page`: integer (default: 50)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "amount": 45.50,
      "type": "expense",
      "description": "Grocery shopping",
      "date": "2025-01-15",
      "category": {
        "id": 3,
        "name": "Food & Dining",
        "icon": "utensils",
        "color": "#FF6B6B"
      },
      "source": "manual",
      "attachments": [],
      "created_at": "2025-01-15T14:20:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 156,
    "per_page": 50
  }
}
```

##### POST /transactions
Create a new transaction.

**Request:**
```json
{
  "amount": 45.50,
  "type": "expense",
  "description": "Grocery shopping",
  "date": "2025-01-15",
  "category_id": 3,
  "source": "manual"
}
```

**Response (201):**
```json
{
  "data": {
    "id": 1,
    "amount": 45.50,
    "type": "expense",
    "description": "Grocery shopping",
    "date": "2025-01-15",
    "category": {
      "id": 3,
      "name": "Food & Dining"
    },
    "source": "manual",
    "created_at": "2025-01-15T14:20:00Z"
  }
}
```

##### GET /transactions/{id}
Get single transaction.

##### PUT /transactions/{id}
Update transaction.

##### DELETE /transactions/{id}
Delete transaction.

---

#### Categories

##### GET /categories
List all categories.

**Query Parameters:**
- `type`: expense | income

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Food & Dining",
      "type": "expense",
      "is_predefined": true,
      "icon": "utensils",
      "color": "#FF6B6B"
    },
    {
      "id": 15,
      "name": "Crypto Trading",
      "type": "income",
      "is_predefined": false,
      "icon": "bitcoin",
      "color": "#F7931A"
    }
  ]
}
```

##### POST /categories
Create custom category.

**Request:**
```json
{
  "name": "Pet Care",
  "type": "expense",
  "icon": "paw",
  "color": "#8B4513"
}
```

##### PUT /categories/{id}
Update category (only custom categories).

##### DELETE /categories/{id}
Delete category (only custom categories).

---

#### Budgets

##### GET /budgets
List budgets.

**Query Parameters:**
- `month`: 1-12
- `year`: YYYY

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "category": {
        "id": 3,
        "name": "Food & Dining"
      },
      "month": 1,
      "year": 2025,
      "amount": 500.00,
      "spent": 342.50,
      "remaining": 157.50,
      "percentage": 68.5
    }
  ]
}
```

##### POST /budgets
Create budget.

**Request:**
```json
{
  "category_id": 3,
  "month": 1,
  "year": 2025,
  "amount": 500.00
}
```

##### PUT /budgets/{id}
Update budget.

##### DELETE /budgets/{id}
Delete budget.

---

#### Upload & OCR

##### POST /uploads/receipt
Upload receipt or invoice for OCR processing.

**Request (multipart/form-data):**
```
file: [binary]
```

**Response (202):**
```json
{
  "attachment_id": 123,
  "status": "processing",
  "message": "Receipt uploaded and queued for processing"
}
```

##### POST /uploads/bank-statement
Upload bank statement PDF.

**Request (multipart/form-data):**
```
file: [binary]
month: 1
year: 2025
```

**Response (202):**
```json
{
  "job_id": "abc-123-def-456",
  "status": "processing",
  "message": "Bank statement uploaded and queued for processing"
}
```

##### GET /uploads/{attachment_id}/status
Check OCR processing status.

**Response (200):**
```json
{
  "attachment_id": 123,
  "status": "completed",
  "transaction": {
    "id": 456,
    "amount": 89.99,
    "description": "Amazon Prime Subscription",
    "date": "2025-01-15"
  }
}
```

---

#### AI Chat

##### POST /ai/chat
Send message to AI assistant.

**Request:**
```json
{
  "message": "How much did I spend on food last month?",
  "conversation_id": 1
}
```

**Response (200):**
```json
{
  "conversation_id": 1,
  "response": "Last month you spent $342.50 on Food & Dining. This is 15% less than the previous month ($403.00). Your top 3 expenses were:\n1. Restaurant dinner on Jan 10 - $85.00\n2. Weekly groceries - $67.50\n3. Coffee shop visits - $45.00",
  "tool_calls": [
    {
      "tool": "list_transactions",
      "parameters": {
        "category": "Food & Dining",
        "from_date": "2024-12-01",
        "to_date": "2024-12-31"
      }
    }
  ]
}
```

##### GET /ai/conversations
List user's conversations.

##### DELETE /ai/conversations/{id}
Delete conversation.

---

#### Analytics

##### GET /analytics/overview
Get financial overview.

**Query Parameters:**
- `month`: 1-12
- `year`: YYYY

**Response (200):**
```json
{
  "period": {
    "month": 1,
    "year": 2025
  },
  "summary": {
    "total_income": 3500.00,
    "total_expenses": 2345.67,
    "net": 1154.33,
    "savings_rate": 33.0
  },
  "expenses_by_category": [
    {
      "category": "Food & Dining",
      "amount": 342.50,
      "percentage": 14.6
    }
  ],
  "budget_status": {
    "categories_on_track": 8,
    "categories_over_budget": 2,
    "total_budget": 2500.00,
    "total_spent": 2345.67
  }
}
```

##### GET /analytics/trends
Get spending trends.

**Query Parameters:**
- `months`: integer (default: 6)

##### POST /analytics/detect-overspending
Detect overspending patterns.

**Response (200):**
```json
{
  "overspending_categories": [
    {
      "category": "Entertainment",
      "current_month": 450.00,
      "average": 280.00,
      "deviation_percentage": 60.7,
      "recommendation": "Your entertainment spending is 60% above your usual average. Consider reviewing subscriptions and discretionary entertainment expenses."
    }
  ]
}
```

##### POST /analytics/detect-recurring
Detect recurring expenses.

**Response (200):**
```json
{
  "recurring_expenses": [
    {
      "description": "Netflix Subscription",
      "amount": 15.99,
      "frequency": "monthly",
      "category": "Subscriptions",
      "confidence": 0.95,
      "occurrences": [
        "2024-12-15",
        "2024-11-15",
        "2024-10-15"
      ]
    }
  ]
}
```

##### POST /analytics/optimization-plan
Generate personalized optimization plan.

**Response (200):**
```json
{
  "optimization_plan": {
    "potential_savings": 385.00,
    "recommendations": [
      {
        "category": "Subscriptions",
        "current_spending": 89.99,
        "action": "Review and cancel unused subscriptions",
        "potential_savings": 45.00,
        "priority": "high"
      },
      {
        "category": "Food & Dining",
        "current_spending": 450.00,
        "action": "Reduce restaurant visits, increase home cooking",
        "potential_savings": 150.00,
        "priority": "medium"
      }
    ]
  }
}
```

---

## 6. AI Integration

### Claude API Configuration

**Model:** `claude-3-5-sonnet-20241022`

**System Prompt:**
```
You are a personal finance assistant helping users manage their money. You have access to their transaction history, budgets, and spending patterns.

Your role is to:
1. Help users add transactions through natural conversation
2. Answer questions about their spending
3. Provide insights and recommendations
4. Detect patterns and anomalies
5. Generate actionable optimization plans

Always be:
- Precise with numbers
- Supportive and non-judgmental
- Focused on actionable advice
- Clear about data sources

When users ask about transactions, always provide specific amounts, dates, and categories.
```

### Tool Definitions

#### Tool 1: create_transaction
```json
{
  "name": "create_transaction",
  "description": "Create a new expense or income transaction",
  "input_schema": {
    "type": "object",
    "properties": {
      "amount": {
        "type": "number",
        "description": "Transaction amount"
      },
      "type": {
        "type": "string",
        "enum": ["expense", "income"],
        "description": "Transaction type"
      },
      "description": {
        "type": "string",
        "description": "Transaction description"
      },
      "date": {
        "type": "string",
        "description": "Transaction date (YYYY-MM-DD)"
      },
      "category_name": {
        "type": "string",
        "description": "Category name (e.g., 'Food & Dining')"
      }
    },
    "required": ["amount", "type", "description", "category_name"]
  }
}
```

#### Tool 2: list_transactions
```json
{
  "name": "list_transactions",
  "description": "List transactions with optional filtering",
  "input_schema": {
    "type": "object",
    "properties": {
      "type": {
        "type": "string",
        "enum": ["expense", "income"],
        "description": "Filter by transaction type"
      },
      "category_name": {
        "type": "string",
        "description": "Filter by category name"
      },
      "from_date": {
        "type": "string",
        "description": "Start date (YYYY-MM-DD)"
      },
      "to_date": {
        "type": "string",
        "description": "End date (YYYY-MM-DD)"
      },
      "limit": {
        "type": "integer",
        "description": "Maximum number of results"
      }
    }
  }
}
```

#### Tool 3: summarize_month
```json
{
  "name": "summarize_month",
  "description": "Get financial summary for a specific month",
  "input_schema": {
    "type": "object",
    "properties": {
      "month": {
        "type": "integer",
        "description": "Month (1-12)"
      },
      "year": {
        "type": "integer",
        "description": "Year (YYYY)"
      }
    },
    "required": ["month", "year"]
  }
}
```

#### Tool 4: detect_overspending
```json
{
  "name": "detect_overspending",
  "description": "Analyze spending patterns to detect overspending",
  "input_schema": {
    "type": "object",
    "properties": {
      "month": {
        "type": "integer",
        "description": "Month to analyze (1-12)"
      },
      "year": {
        "type": "integer",
        "description": "Year to analyze (YYYY)"
      }
    }
  }
}
```

#### Tool 5: detect_recurring_expenses
```json
{
  "name": "detect_recurring_expenses",
  "description": "Identify recurring expenses from transaction history",
  "input_schema": {
    "type": "object",
    "properties": {
      "lookback_months": {
        "type": "integer",
        "description": "Number of months to analyze (default: 6)"
      }
    }
  }
}
```

#### Tool 6: generate_optimization_plan
```json
{
  "name": "generate_optimization_plan",
  "description": "Generate personalized financial optimization recommendations",
  "input_schema": {
    "type": "object",
    "properties": {}
  }
}
```

### Example Chat Interactions

**Example 1: Adding a transaction**
```
User: I just spent $45.50 at Whole Foods

AI processes:
1. Detects intent: create transaction
2. Calls tool: create_transaction
   - amount: 45.50
   - type: expense
   - description: "Whole Foods"
   - category_name: "Food & Dining"
   - date: today

AI responds: "I've added your $45.50 grocery expense at Whole Foods to your Food & Dining category. You've spent $342.50 on food this month, which is within your $500 budget."
```

**Example 2: Analyzing spending**
```
User: How much did I spend on transportation last month?

AI processes:
1. Detects intent: query transactions
2. Calls tool: list_transactions
   - type: expense
   - category_name: "Transportation"
   - from_date: "2024-12-01"
   - to_date: "2024-12-31"

AI responds: "Last month you spent $287.00 on transportation:
- Gas: $145.00 (4 transactions)
- Uber/Lyft: $89.00 (6 rides)
- Parking: $53.00 (3 transactions)

This is 12% higher than your November spending of $256.00."
```

**Example 3: Getting recommendations**
```
User: Can you help me save money?

AI processes:
1. Detects intent: optimization
2. Calls tool: generate_optimization_plan

AI responds: "I've analyzed your spending and found 3 opportunities to save $385/month:

1. **Subscriptions ($45/month potential savings)**
   - You have 7 active subscriptions totaling $89.99/month
   - Netflix, Spotify, and Disney+ appear unused (no streaming activity detected)

2. **Food & Dining ($150/month potential savings)**
   - Your restaurant spending averages $280/month
   - Reducing dining out by 2x per week could save $150

3. **Utilities ($40/month potential savings)**
   - Your electricity bill increased 23% this quarter
   - Consider adjusting thermostat settings

Would you like me to create a detailed action plan for any of these?"
```

---

## 7. Security

### Authentication & Authorization
- **Token-based Auth**: Laravel Sanctum with SPA authentication
- **Token Expiration**: 24 hours (configurable)
- **Password Requirements**: Minimum 8 characters, must include uppercase, lowercase, number, special character
- **Rate Limiting**:
  - Login: 5 attempts per 15 minutes
  - API calls: 60 per minute per user
  - File uploads: 10 per hour

### Data Protection
- **Encryption at Rest**: PostgreSQL encryption enabled
- **Encryption in Transit**: HTTPS/TLS 1.3 only
- **Password Hashing**: bcrypt with cost factor 12
- **Sensitive Data**: Financial amounts stored as DECIMAL(15,2)

### File Upload Security
- **Allowed Types**: PDF, PNG, JPG, JPEG only
- **Max File Size**: 10MB per file
- **Virus Scanning**: ClamAV integration recommended
- **Storage**: Private S3 bucket or local storage with signed URLs
- **Filename Sanitization**: UUID-based naming to prevent path traversal

### API Security
- **CORS**: Whitelist frontend domain only
- **CSRF Protection**: Enabled for cookie-based auth
- **Input Validation**: All requests validated via Form Requests
- **SQL Injection Prevention**: Eloquent ORM with parameter binding
- **XSS Prevention**: Output escaping in responses

### Third-Party API Security
- **Claude API Key**: Stored in environment variables
- **Key Rotation**: Monthly rotation recommended
- **Request Logging**: All AI requests logged for audit
- **PII Handling**: Minimal financial data sent to Claude (aggregated only)

---

## 8. Deployment

### Prerequisites
- **Server**: Ubuntu 22.04 LTS or higher
- **PHP**: 8.3+ with extensions (pdo, pdo_pgsql, mbstring, openssl, tokenizer, xml, ctype, json, bcmath, redis)
- **PostgreSQL**: 15+
- **Redis**: 7+
- **Nginx**: 1.24+
- **Node.js**: 20+ LTS
- **Tesseract OCR**: 5+

### Environment Variables

**Backend (.env)**
```env
APP_NAME=FinanceChat
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://api.financechat.com

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=financechat
DB_USERNAME=financechat_user
DB_PASSWORD=secure_password

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

QUEUE_CONNECTION=redis

CLAUDE_API_KEY=sk-ant-...
CLAUDE_MODEL=claude-3-5-sonnet-20241022

FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=financechat-uploads

SANCTUM_STATEFUL_DOMAINS=app.financechat.com
SESSION_DOMAIN=.financechat.com
```

**Frontend (.env.local)**
```env
NEXT_PUBLIC_API_URL=https://api.financechat.com/api
NEXT_PUBLIC_APP_NAME=FinanceChat
```

### Deployment Steps

#### Backend (Laravel)
```bash
# 1. Clone repository
git clone https://github.com/yourorg/financechat-backend.git
cd financechat-backend

# 2. Install dependencies
composer install --optimize-autoloader --no-dev

# 3. Setup environment
cp .env.example .env
php artisan key:generate

# 4. Run migrations
php artisan migrate --force

# 5. Seed predefined categories
php artisan db:seed --class=CategorySeeder

# 6. Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Setup queue worker (systemd)
sudo systemctl enable financechat-worker
sudo systemctl start financechat-worker

# 8. Setup scheduler (cron)
* * * * * cd /var/www/financechat && php artisan schedule:run >> /dev/null 2>&1
```

#### Frontend (Next.js)
```bash
# 1. Clone repository
git clone https://github.com/yourorg/financechat-frontend.git
cd financechat-frontend

# 2. Install dependencies
npm ci

# 3. Build
npm run build

# 4. Start (with PM2)
pm2 start npm --name "financechat-frontend" -- start
pm2 save
pm2 startup
```

### Nginx Configuration

**API (api.financechat.com)**
```nginx
server {
    listen 443 ssl http2;
    server_name api.financechat.com;

    ssl_certificate /etc/letsencrypt/live/api.financechat.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.financechat.com/privkey.pem;

    root /var/www/financechat-backend/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    client_max_body_size 10M;
}
```

**Frontend (app.financechat.com)**
```nginx
server {
    listen 443 ssl http2;
    server_name app.financechat.com;

    ssl_certificate /etc/letsencrypt/live/app.financechat.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.financechat.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Monitoring & Maintenance
- **Logs**: `/var/www/financechat-backend/storage/logs`
- **Queue Monitoring**: Laravel Horizon (optional)
- **Uptime Monitoring**: UptimeRobot or Pingdom
- **Error Tracking**: Sentry integration
- **Database Backups**: Daily automated backups to S3
- **Health Check Endpoint**: `/api/health`

---

## Appendix: Suggested Premium Features

### Future Enhancements
1. **Multi-currency Support**
2. **Bank Account Integration** (Plaid API)
3. **Investment Portfolio Tracking**
4. **Goal Setting & Progress Tracking**
5. **Shared Budgets** (multi-user households)
6. **Advanced Reports & Exports** (PDF, Excel)
7. **Mobile Native Apps** (React Native)
8. **Voice Input** (speech-to-transaction)
9. **Smart Notifications** (budget alerts, bill reminders)
10. **Tax Category Tagging** (for tax preparation)

---

**Document Version**: 1.0
**Last Updated**: 2025-01-24
**Author**: System Architecture Team
