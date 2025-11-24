# Wireframes and Usage Examples - FinanceChat

ASCII wireframes and example interactions for all major features.

---

## Table of Contents
1. [Page Wireframes](#page-wireframes)
2. [Chat Interaction Examples](#chat-interaction-examples)
3. [API Request/Response Examples](#api-requestresponse-examples)
4. [User Workflows](#user-workflows)

---

## 1. Page Wireframes

### Login Page

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                                                            │
│                   FinanceChat Logo                         │
│                                                            │
│         ┌──────────────────────────────────────┐          │
│         │                                      │          │
│         │   Welcome to FinanceChat             │          │
│         │   Sign in to your account            │          │
│         │                                      │          │
│         │   Email                              │          │
│         │   ┌────────────────────────────────┐ │          │
│         │   │ you@example.com                │ │          │
│         │   └────────────────────────────────┘ │          │
│         │                                      │          │
│         │   Password                           │          │
│         │   ┌────────────────────────────────┐ │          │
│         │   │ ••••••••                       │ │          │
│         │   └────────────────────────────────┘ │          │
│         │                                      │          │
│         │   ┌────────────────────────────────┐ │          │
│         │   │         Sign In                │ │          │
│         │   └────────────────────────────────┘ │          │
│         │                                      │          │
│         │   Don't have an account? Sign up    │          │
│         │                                      │          │
│         └──────────────────────────────────────┘          │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

### Dashboard Page

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ FinanceChat                                        Welcome back, John ⚫     │
├──────────┬───────────────────────────────────────────────────────────────────┤
│          │  Dashboard                                                        │
│          │  Overview of your financial activity this month                  │
│          │                                                                   │
│ Dashboard│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐       │
│          │  │  📈       │ │  📉       │ │  💵       │ │  💰       │       │
│ Trans.   │  │ Income    │ │ Expenses  │ │ Net       │ │ Savings   │       │
│          │  │ $3,500.00 │ │ $2,345.67 │ │ $1,154.33 │ │ 33.0%     │       │
│ AI Chat  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘       │
│          │                                                                   │
│ Budgets  │  ┌─────────────────────────┐ ┌─────────────────────────┐       │
│          │  │ Spending Trend          │ │ Category Breakdown      │       │
│ Analytics│  │                         │ │                         │       │
│          │  │      ╱╲   ╱╲           │ │  Food ████████ 28%      │       │
│ Settings │  │     ╱  ╲ ╱  ╲          │ │  Trans ████ 15%         │       │
│          │  │    ╱    ╲    ╲         │ │  Housing ███████ 25%    │       │
│          │  │   ╱      ╲    ╲        │ │  Utils ███ 12%          │       │
│          │  │  ╱        ╲────╲       │ │  Other ████████ 20%     │       │
│          │  │                         │ │                         │       │
│          │  └─────────────────────────┘ └─────────────────────────┘       │
│          │                                                                   │
│          │  ┌─────────────────────────┐ ┌─────────────────────────┐       │
│          │  │ Recent Transactions     │ │ Budget Progress         │       │
│ ────────│  │                         │ │                         │       │
│          │  │ 🍔 Lunch at Chipotle   │ │ Food & Dining           │       │
│ Logout   │  │    $15.50   Today       │ │ ████████░░░ 68%        │       │
│          │  │                         │ │ $342/$500               │       │
│          │  │ 🚗 Gas Station         │ │                         │       │
│          │  │    $45.00   Yesterday   │ │ Transportation          │       │
│          │  │                         │ │ ███████░░░░ 55%        │       │
│          │  │ 💻 Netflix             │ │ $165/$300               │       │
│          │  │    $15.99   Jan 15      │ │                         │       │
│          │  └─────────────────────────┘ └─────────────────────────┘       │
└──────────┴───────────────────────────────────────────────────────────────────┘
```

---

### Transactions Page

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ FinanceChat                                        Welcome back, John ⚫     │
├──────────┬───────────────────────────────────────────────────────────────────┤
│          │  Transactions                          [+ Add Transaction]        │
│          │  View and manage your transactions                               │
│          │                                                                   │
│ Dashboard│  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ Filters:                                                     ││
│ Trans.   │  │ [All Types ▾] [All Categories ▾] [Jan 1 - Jan 31] [Apply]   ││
│  ◀───    │  └──────────────────────────────────────────────────────────────┘│
│          │                                                                   │
│ AI Chat  │  ┌──────────────────────────────────────────────────────────────┐│
│          │  │                                                              ││
│ Budgets  │  │  Jan 24, 2025                                                ││
│          │  │  ┌─────────────────────────────────────────────────────┐    ││
│ Analytics│  │  │ 🍔  Lunch at Chipotle          Today      -$15.50   │    ││
│          │  │  │     Food & Dining                                    │    ││
│ Settings │  │  └─────────────────────────────────────────────────────┘    ││
│          │  │                                                              ││
│          │  │  ┌─────────────────────────────────────────────────────┐    ││
│          │  │  │ 🚗  Shell Gas Station          Today      -$45.00   │    ││
│          │  │  │     Transportation                                   │    ││
│          │  │  └─────────────────────────────────────────────────────┘    ││
│          │  │                                                              ││
│          │  │  Jan 23, 2025                                                ││
│ ────────│  │  ┌─────────────────────────────────────────────────────┐    ││
│          │  │  │ 💻  Netflix Subscription      Yesterday   -$15.99   │    ││
│ Logout   │  │  │     Subscriptions                                    │    ││
│          │  │  └─────────────────────────────────────────────────────┘    ││
│          │  │                                                              ││
│          │  │  ┌─────────────────────────────────────────────────────┐    ││
│          │  │  │ 💰  Salary Payment            Yesterday   +$3500.00 │    ││
│          │  │  │     Salary                                           │    ││
│          │  │  └─────────────────────────────────────────────────────┘    ││
│          │  │                                                              ││
│          │  │                    [Load More]                               ││
│          │  └──────────────────────────────────────────────────────────────┘│
└──────────┴───────────────────────────────────────────────────────────────────┘
```

---

### AI Chat Page

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ FinanceChat                                        Welcome back, John ⚫     │
├──────────┬───────────────────────────────────────────────────────────────────┤
│          │  AI Assistant                                                     │
│          │  Ask questions about your finances or add transactions naturally │
│          │                                                                   │
│ Dashboard│  ┌──────────────────────────────────────────────────────────────┐│
│          │  │                                                              ││
│ Trans.   │  │  🤖 Hello! I'm your finance assistant. How can I help       ││
│          │  │     you today? You can ask about your spending, add          ││
│ AI Chat  │  │     transactions, or get financial insights.                 ││
│  ◀───    │  │                                                              ││
│          │  │                                                              ││
│ Budgets  │  │                          How much did I spend on food? 👤    ││
│          │  │                                                              ││
│ Analytics│  │  🤖 Last month you spent $342.50 on Food & Dining. This     ││
│          │  │     is 15% less than the previous month ($403.00). Your      ││
│ Settings │  │     top 3 expenses were:                                     ││
│          │  │     1. Restaurant dinner on Jan 10 - $85.00                  ││
│          │  │     2. Weekly groceries - $67.50                             ││
│          │  │     3. Coffee shop visits - $45.00                           ││
│          │  │                                                              ││
│          │  │                    I just spent $45 at Whole Foods 👤        ││
│          │  │                                                              ││
│          │  │  🤖 I've added your $45.00 grocery expense at Whole Foods   ││
│ ────────│  │     to your Food & Dining category. You've spent $342.50     ││
│          │  │     on food this month, which is within your $500 budget.    ││
│ Logout   │  │                                                              ││
│          │  │                                                              ││
│          │  └──────────────────────────────────────────────────────────────┘│
│          │  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ Type your message...                              [Send] 📤 ││
│          │  └──────────────────────────────────────────────────────────────┘│
└──────────┴───────────────────────────────────────────────────────────────────┘
```

---

### Budgets Page

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ FinanceChat                                        Welcome back, John ⚫     │
├──────────┬───────────────────────────────────────────────────────────────────┤
│          │  Budgets                                     [+ Add Budget]       │
│          │  Set and track monthly spending limits                           │
│          │                                                                   │
│ Dashboard│  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ January 2025                                                 ││
│ Trans.   │  └──────────────────────────────────────────────────────────────┘│
│          │                                                                   │
│ AI Chat  │  ┌─────────────────────────┐ ┌─────────────────────────┐        │
│          │  │ Food & Dining           │ │ Transportation          │        │
│ Budgets  │  │ Budget: $500            │ │ Budget: $300            │        │
│  ◀───    │  │ Spent: $342.50          │ │ Spent: $165.00          │        │
│          │  │                         │ │                         │        │
│ Analytics│  │ ████████████░░░░░       │ │ ███████░░░░░░░░░        │        │
│          │  │ 68% ($157.50 left)      │ │ 55% ($135.00 left)      │        │
│ Settings │  │                         │ │                         │        │
│          │  │ ✅ On Track             │ │ ✅ On Track             │        │
│          │  └─────────────────────────┘ └─────────────────────────┘        │
│          │                                                                   │
│          │  ┌─────────────────────────┐ ┌─────────────────────────┐        │
│          │  │ Housing                 │ │ Entertainment           │        │
│          │  │ Budget: $1,500          │ │ Budget: $200            │        │
│ ────────│  │ Spent: $1,500.00        │ │ Spent: $245.00          │        │
│          │  │                         │ │                         │        │
│ Logout   │  │ ████████████████████    │ │ ███████████████████████ │        │
│          │  │ 100% (Budget met)       │ │ 122% ($45.00 over)      │        │
│          │  │                         │ │                         │        │
│          │  │ ⚠️  Budget Reached      │ │ ⚠️  Over Budget!        │        │
│          │  └─────────────────────────┘ └─────────────────────────┘        │
└──────────┴───────────────────────────────────────────────────────────────────┘
```

---

### Analytics Page

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ FinanceChat                                        Welcome back, John ⚫     │
├──────────┬───────────────────────────────────────────────────────────────────┤
│          │  Analytics                                                        │
│          │  Insights and recommendations for your finances                  │
│          │                                                                   │
│ Dashboard│  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ 📊 Spending Trends (Last 6 Months)                           ││
│ Trans.   │  │                                                              ││
│          │  │  3500├──────────────────────────────────────────            ││
│ AI Chat  │  │      │                              ╱╲                       ││
│          │  │  3000│                         ╱╲  ╱  ╲                      ││
│ Budgets  │  │      │                    ╱╲  ╱  ╲╱    ╲                     ││
│          │  │  2500│               ╱╲  ╱  ╲╱            ╲                   ││
│ Analytics│  │      │          ╱╲  ╱  ╲╱                  ╲                  ││
│  ◀───    │  │  2000│     ╱╲  ╱  ╲╱                        ╲                 ││
│          │  │      │────╱──╲╱────────────────────────────────             ││
│ Settings │  │        Aug Sep Oct Nov Dec Jan                               ││
│          │  └──────────────────────────────────────────────────────────────┘│
│          │                                                                   │
│          │  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ ⚠️  Overspending Detected                                    ││
│          │  │                                                              ││
│          │  │  • Entertainment: $245 (22% above average)                   ││
│          │  │    Your entertainment spending is elevated. Consider free    ││
│          │  │    alternatives.                                             ││
│          │  │                                                              ││
│ ────────│  │  • Shopping: $380 (35% above average)                        ││
│          │  │    Implement a 24-hour rule before making purchases.         ││
│ Logout   │  └──────────────────────────────────────────────────────────────┘│
│          │                                                                   │
│          │  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ 🔁 Recurring Expenses (6 detected)                           ││
│          │  │                                                              ││
│          │  │  • Netflix - $15.99/month                                    ││
│          │  │  • Spotify - $9.99/month                                     ││
│          │  │  • Gym Membership - $50.00/month                             ││
│          │  │  • Phone Bill - $75.00/month                                 ││
│          │  │                                               [View All]      ││
│          │  └──────────────────────────────────────────────────────────────┘│
│          │                                                                   │
│          │  ┌──────────────────────────────────────────────────────────────┐│
│          │  │ 💡 Optimization Recommendations                              ││
│          │  │                                                              ││
│          │  │  Potential Monthly Savings: $385                             ││
│          │  │                                                              ││
│          │  │  1. Review subscriptions ($45 savings)                       ││
│          │  │     Cancel unused streaming services                         ││
│          │  │                                                              ││
│          │  │  2. Reduce dining out ($150 savings)                         ││
│          │  │     Cook at home 2 more times per week                       ││
│          │  │                                                              ││
│          │  │  3. Optimize utilities ($40 savings)                         ││
│          │  │     Adjust thermostat settings                               ││
│          │  └──────────────────────────────────────────────────────────────┘│
└──────────┴───────────────────────────────────────────────────────────────────┘
```

---

## 2. Chat Interaction Examples

### Example 1: Adding a Transaction

```
User:    I just spent $45.50 at Whole Foods

AI:      I've added your $45.50 grocery expense at Whole Foods to your
         Food & Dining category. You've spent $342.50 on food this month,
         which is within your $500 budget.

         [Transaction created: #1234]
         - Amount: $45.50
         - Category: Food & Dining
         - Date: Today
```

---

### Example 2: Querying Spending

```
User:    How much did I spend on transportation last month?

AI:      Last month you spent $287.00 on transportation:
         • Gas: $145.00 (4 transactions)
         • Uber/Lyft: $89.00 (6 rides)
         • Parking: $53.00 (3 transactions)

         This is 12% higher than your November spending of $256.00.
```

---

### Example 3: Budget Analysis

```
User:    Am I staying within my budgets?

AI:      Here's your budget status for January:

         ✅ On Track (6 categories):
         • Food & Dining: 68% ($342/$500)
         • Transportation: 55% ($165/$300)
         • Utilities: 80% ($160/$200)
         • Personal Care: 45% ($45/$100)
         • Education: 0% ($0/$200)
         • Travel: 0% ($0/$500)

         ⚠️ Over Budget (2 categories):
         • Entertainment: 122% ($245/$200) - $45 over
         • Shopping: 127% ($380/$300) - $80 over

         Recommendation: You're $125 over budget in total. Consider
         reducing discretionary spending in Entertainment and Shopping
         for the remainder of the month.
```

---

### Example 4: Monthly Comparison

```
User:    Compare my spending this month to last month

AI:      January 2025 vs December 2024:

         Total Spending:
         • January: $2,345.67
         • December: $2,789.45
         • Change: -$443.78 (-15.9%) 📉

         Top Changes:
         • Shopping: -45% ($380 vs $692) 📉 Great improvement!
         • Food & Dining: +8% ($342 vs $317) 📈 Slight increase
         • Entertainment: +35% ($245 vs $182) 📈 Watch this

         You're doing better this month! Keep up the good work on
         reducing shopping expenses.
```

---

### Example 5: Getting Savings Recommendations

```
User:    Can you help me save money?

AI:      I've analyzed your spending and found 3 opportunities to save
         $385/month:

         1. 💳 Subscriptions ($45/month potential savings)
            You have 7 active subscriptions totaling $89.99/month:
            - Netflix, Spotify, Disney+, HBO Max, Apple Music,
              Adobe Creative Cloud, YouTube Premium

            Recommendation: Cancel Netflix and HBO Max (duplicates),
            use family plan for Spotify instead of individual.

         2. 🍔 Food & Dining ($150/month potential savings)
            Your restaurant spending averages $280/month.

            Recommendation: Reduce dining out from 8x to 4x per week.
            Meal prep on Sundays. Expected savings: $150/month.

         3. ⚡ Utilities ($40/month potential savings)
            Your electricity bill increased 23% this quarter.

            Recommendation: Adjust thermostat by 2°, use LED bulbs,
            unplug unused devices. Expected savings: $40/month.

         Would you like me to create a detailed action plan for any
         of these?
```

---

### Example 6: Receipt Upload (via Chat)

```
User:    I have a receipt from Target, can I upload it?

AI:      Yes! You can upload receipts directly. I'll extract the amount
         and details automatically.

         [Upload Button appears]

User:    [uploads receipt image]

AI:      Processing your receipt...

         ✅ Receipt processed successfully!

         I found:
         • Merchant: Target
         • Amount: $67.89
         • Date: Jan 24, 2025
         • Items: Various household goods

         I've categorized this as "Shopping". Is that correct?

User:    Yes, that's right

AI:      Great! Transaction saved.

         [Transaction #1235]
         - Amount: $67.89
         - Category: Shopping
         - Date: Jan 24, 2025
         - Source: Receipt OCR
```

---

## 3. API Request/Response Examples

### Example 1: Create Transaction

**Request:**
```http
POST /api/transactions
Authorization: Bearer {token}
Content-Type: application/json

{
  "amount": 45.50,
  "type": "expense",
  "description": "Lunch at Chipotle",
  "date": "2025-01-24",
  "category_id": 3,
  "source": "manual"
}
```

**Response:**
```json
{
  "data": {
    "id": 1234,
    "amount": "45.50",
    "type": "expense",
    "description": "Lunch at Chipotle",
    "date": "2025-01-24",
    "category": {
      "id": 3,
      "name": "Food & Dining",
      "icon": "utensils",
      "color": "#FF6B6B"
    },
    "source": "manual",
    "attachments": [],
    "created_at": "2025-01-24T14:30:00Z",
    "updated_at": "2025-01-24T14:30:00Z"
  }
}
```

---

### Example 2: Chat Message with Tool Call

**Request:**
```http
POST /api/ai/chat
Authorization: Bearer {token}
Content-Type: application/json

{
  "message": "How much did I spend on food last month?",
  "conversation_id": 1
}
```

**Response:**
```json
{
  "conversation_id": 1,
  "response": "Last month you spent $342.50 on Food & Dining. This is 15% less than the previous month ($403.00). Your top 3 expenses were:\n1. Restaurant dinner on Jan 10 - $85.00\n2. Weekly groceries - $67.50\n3. Coffee shop visits - $45.00",
  "tool_calls": [
    {
      "tool": "list_transactions",
      "parameters": {
        "type": "expense",
        "category_name": "Food & Dining",
        "from_date": "2024-12-01",
        "to_date": "2024-12-31"
      }
    }
  ]
}
```

---

### Example 3: Get Analytics Overview

**Request:**
```http
GET /api/analytics/overview?month=1&year=2025
Authorization: Bearer {token}
```

**Response:**
```json
{
  "period": {
    "month": 1,
    "year": 2025
  },
  "summary": {
    "total_income": "3500.00",
    "total_expenses": "2345.67",
    "net": "1154.33",
    "savings_rate": 33.0
  },
  "expenses_by_category": [
    {
      "category": "Food & Dining",
      "amount": "342.50",
      "percentage": 14.6
    },
    {
      "category": "Transportation",
      "amount": "165.00",
      "percentage": 7.0
    },
    {
      "category": "Housing",
      "amount": "1500.00",
      "percentage": 63.9
    }
  ],
  "budget_status": {
    "categories_on_track": 8,
    "categories_over_budget": 2,
    "total_budget": "2500.00",
    "total_spent": "2345.67"
  }
}
```

---

### Example 4: Upload Receipt

**Request:**
```http
POST /api/uploads/receipt
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [binary data]
```

**Response:**
```json
{
  "attachment_id": 123,
  "status": "processing",
  "message": "Receipt uploaded and queued for processing"
}
```

**Check Status:**
```http
GET /api/uploads/123/status
Authorization: Bearer {token}
```

**Status Response (completed):**
```json
{
  "attachment_id": 123,
  "status": "completed",
  "transaction": {
    "id": 456,
    "amount": "89.99",
    "description": "Amazon Prime Subscription",
    "date": "2025-01-15",
    "category": {
      "id": 12,
      "name": "Subscriptions"
    }
  }
}
```

---

## 4. User Workflows

### Workflow 1: New User Onboarding

```
1. User visits app.financechat.com
   ↓
2. Clicks "Sign Up"
   ↓
3. Fills registration form:
   - Name: John Doe
   - Email: john@example.com
   - Password: SecurePass123!
   ↓
4. System creates account
   ↓
5. System copies predefined categories to user
   ↓
6. User is logged in and redirected to dashboard
   ↓
7. Dashboard shows welcome message and empty state
   ↓
8. User clicks "Add Transaction" or "AI Chat" to begin
```

---

### Workflow 2: Adding Expense via Chat

```
1. User navigates to AI Chat page
   ↓
2. Types: "I spent $45 at Starbucks"
   ↓
3. Message sent to backend
   ↓
4. Backend sends to Claude API with tools
   ↓
5. Claude detects create_transaction intent
   ↓
6. Tool call executed:
   - amount: 45
   - type: expense
   - description: "Starbucks"
   - category: Food & Dining (auto-detected)
   - date: today
   ↓
7. Transaction created in database
   ↓
8. Response sent back to Claude
   ↓
9. Claude generates natural language response
   ↓
10. User sees: "I've added your $45.00 expense at Starbucks..."
```

---

### Workflow 3: Uploading Receipt

```
1. User navigates to Transactions page
   ↓
2. Clicks "Upload Receipt" button
   ↓
3. Selects receipt image from device
   ↓
4. File uploaded to backend
   ↓
5. Attachment record created with status: "pending"
   ↓
6. Job dispatched to Redis queue
   ↓
7. Queue worker picks up job
   ↓
8. Tesseract OCR extracts text from image
   ↓
9. Extracted text sent to Claude for parsing
   ↓
10. Claude returns structured data:
    - amount: 89.99
    - merchant: "Amazon"
    - date: 2025-01-15
    - suggested category: "Shopping"
   ↓
11. Transaction auto-created
   ↓
12. Attachment status updated to "completed"
   ↓
13. User receives notification (optional)
   ↓
14. Transaction appears in list
```

---

### Workflow 4: Monthly Budget Review

```
1. User opens Analytics page
   ↓
2. System queries all transactions for current month
   ↓
3. System queries all budgets for current month
   ↓
4. Analytics calculated:
   - Total spent per category
   - Budget vs actual comparison
   - Overspending detection
   - Month-over-month trends
   ↓
5. Charts and visualizations rendered
   ↓
6. User sees:
   - Spending trends graph
   - Category breakdown pie chart
   - Overspending alerts
   - Optimization recommendations
   ↓
7. User can click "Generate Optimization Plan"
   ↓
8. System analyzes:
   - Recurring expenses
   - High-spend categories
   - Historical patterns
   ↓
9. AI generates personalized recommendations
   ↓
10. User reviews action items
```

---

### Workflow 5: Bank Statement Import

```
1. User clicks "Import Bank Statement"
   ↓
2. Upload dialog appears
   ↓
3. User selects:
   - PDF file
   - Month: January
   - Year: 2025
   ↓
4. File uploaded to backend
   ↓
5. ProcessBankStatement job queued
   ↓
6. Job extracts text from PDF (multi-page)
   ↓
7. Text sent to Claude for parsing
   ↓
8. Claude returns array of transactions:
   [
     {date: "2025-01-15", amount: 45.99, description: "Amazon", ...},
     {date: "2025-01-16", amount: 12.50, description: "Starbucks", ...},
     ...
   ]
   ↓
9. System iterates through transactions
   ↓
10. For each transaction:
    - Match category by description
    - Create transaction record
    - Link to bank statement attachment
   ↓
11. Job completes
   ↓
12. User sees notification: "35 transactions imported"
   ↓
13. Transactions appear in list
```

---

## Mobile Responsive Views

### Mobile Dashboard (Portrait)

```
┌─────────────────────────────┐
│ ☰ FinanceChat          ⚫   │
├─────────────────────────────┤
│                             │
│ Welcome back, John          │
│                             │
│ ┌─────────────────────────┐ │
│ │ 📈 Income               │ │
│ │ $3,500.00               │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ 📉 Expenses             │ │
│ │ $2,345.67               │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ 💵 Net                  │ │
│ │ $1,154.33               │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ Category Breakdown      │ │
│ │                         │ │
│ │ Food ████████ 28%       │ │
│ │ Trans ████ 15%          │ │
│ │ Housing ███████ 25%     │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ Recent Transactions     │ │
│ │                         │ │
│ │ 🍔 Chipotle    -$15.50  │ │
│ │ 🚗 Gas         -$45.00  │ │
│ │ 💻 Netflix     -$15.99  │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│ ┌───────────────────┐       │
│ │  + Add Transaction │       │
│ └───────────────────┘       │
│                             │
└─────────────────────────────┘
```

---

**End of Wireframes Document**

**Document Version**: 1.0
**Last Updated**: 2025-01-24
