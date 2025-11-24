# Laravel Backend Structure - FinanceChat

Complete backend implementation with clean architecture.

## Directory Structure

```
financechat-backend/
├── app/
│   ├── Console/
│   │   └── Kernel.php
│   ├── DTOs/
│   │   ├── TransactionDTO.php
│   │   ├── CategoryDTO.php
│   │   ├── BudgetDTO.php
│   │   └── ChatMessageDTO.php
│   ├── Exceptions/
│   │   ├── Handler.php
│   │   └── InsufficientDataException.php
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php
│   │   │   ├── TransactionController.php
│   │   │   ├── CategoryController.php
│   │   │   ├── BudgetController.php
│   │   │   ├── UploadController.php
│   │   │   ├── ChatController.php
│   │   │   └── AnalyticsController.php
│   │   ├── Middleware/
│   │   │   ├── Authenticate.php
│   │   │   └── RateLimiter.php
│   │   ├── Requests/
│   │   │   ├── StoreTransactionRequest.php
│   │   │   ├── UpdateTransactionRequest.php
│   │   │   ├── StoreCategoryRequest.php
│   │   │   ├── StoreBudgetRequest.php
│   │   │   └── ChatMessageRequest.php
│   │   └── Resources/
│   │       ├── TransactionResource.php
│   │       ├── CategoryResource.php
│   │       ├── BudgetResource.php
│   │       └── AnalyticsResource.php
│   ├── Jobs/
│   │   ├── ProcessReceiptOCR.php
│   │   └── ProcessBankStatement.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Transaction.php
│   │   ├── Category.php
│   │   ├── Budget.php
│   │   ├── Attachment.php
│   │   ├── RecurringExpense.php
│   │   └── AiConversation.php
│   ├── Repositories/
│   │   ├── TransactionRepository.php
│   │   ├── CategoryRepository.php
│   │   ├── BudgetRepository.php
│   │   └── ConversationRepository.php
│   ├── Services/
│   │   ├── TransactionService.php
│   │   ├── CategoryService.php
│   │   ├── BudgetService.php
│   │   ├── AnalyticsService.php
│   │   ├── OCRService.php
│   │   ├── ClaudeService.php
│   │   └── ChatService.php
│   └── Providers/
│       ├── AppServiceProvider.php
│       └── RouteServiceProvider.php
├── bootstrap/
├── config/
│   ├── app.php
│   ├── database.php
│   ├── sanctum.php
│   └── services.php
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
├── storage/
├── tests/
│   ├── Feature/
│   │   ├── AuthTest.php
│   │   ├── TransactionTest.php
│   │   └── ChatTest.php
│   └── Unit/
│       ├── TransactionServiceTest.php
│       └── AnalyticsServiceTest.php
├── .env.example
├── composer.json
└── phpunit.xml
```

---

## 1. API Routes

**File**: `routes/api.php`

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\BudgetController;
use App\Http\Controllers\UploadController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\AnalyticsController;

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Transactions
    Route::apiResource('transactions', TransactionController::class);

    // Categories
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::put('/categories/{category}', [CategoryController::class, 'update']);
    Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);

    // Budgets
    Route::apiResource('budgets', BudgetController::class);

    // Uploads
    Route::post('/uploads/receipt', [UploadController::class, 'uploadReceipt']);
    Route::post('/uploads/bank-statement', [UploadController::class, 'uploadBankStatement']);
    Route::get('/uploads/{attachment}/status', [UploadController::class, 'checkStatus']);

    // AI Chat
    Route::post('/ai/chat', [ChatController::class, 'sendMessage']);
    Route::get('/ai/conversations', [ChatController::class, 'listConversations']);
    Route::delete('/ai/conversations/{conversation}', [ChatController::class, 'deleteConversation']);

    // Analytics
    Route::get('/analytics/overview', [AnalyticsController::class, 'overview']);
    Route::get('/analytics/trends', [AnalyticsController::class, 'trends']);
    Route::post('/analytics/detect-overspending', [AnalyticsController::class, 'detectOverspending']);
    Route::post('/analytics/detect-recurring', [AnalyticsController::class, 'detectRecurring']);
    Route::post('/analytics/optimization-plan', [AnalyticsController::class, 'generateOptimizationPlan']);

    // Health check
    Route::get('/health', fn() => response()->json(['status' => 'ok']));
});
```

---

## 2. Models

### User Model

**File**: `app/Models/User.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function budgets()
    {
        return $this->hasMany(Budget::class);
    }

    public function conversations()
    {
        return $this->hasMany(AiConversation::class);
    }

    public function recurringExpenses()
    {
        return $this->hasMany(RecurringExpense::class);
    }
}
```

### Transaction Model

**File**: `app/Models/Transaction.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category_id',
        'amount',
        'type',
        'description',
        'date',
        'source',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'date' => 'date',
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function attachments()
    {
        return $this->hasMany(Attachment::class);
    }

    public function scopeExpenses($query)
    {
        return $query->where('type', 'expense');
    }

    public function scopeIncomes($query)
    {
        return $query->where('type', 'income');
    }

    public function scopeInDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }
}
```

### Category Model

**File**: `app/Models/Category.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'type',
        'is_predefined',
        'icon',
        'color',
    ];

    protected $casts = [
        'is_predefined' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function budgets()
    {
        return $this->hasMany(Budget::class);
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where(function ($q) use ($userId) {
            $q->where('user_id', $userId)
              ->orWhereNull('user_id'); // Include predefined categories
        });
    }

    public function scopeExpenseCategories($query)
    {
        return $query->where('type', 'expense');
    }

    public function scopeIncomeCategories($query)
    {
        return $query->where('type', 'income');
    }
}
```

### Budget Model

**File**: `app/Models/Budget.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Budget extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category_id',
        'month',
        'year',
        'amount',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'month' => 'integer',
        'year' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function scopeForPeriod($query, $month, $year)
    {
        return $query->where('month', $month)->where('year', $year);
    }
}
```

### Attachment Model

**File**: `app/Models/Attachment.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'transaction_id',
        'file_path',
        'file_type',
        'file_size',
        'ocr_status',
        'ocr_text',
    ];

    protected $casts = [
        'ocr_text' => 'array',
        'file_size' => 'integer',
    ];

    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }

    public function scopePending($query)
    {
        return $query->where('ocr_status', 'pending');
    }

    public function scopeProcessing($query)
    {
        return $query->where('ocr_status', 'processing');
    }

    public function scopeCompleted($query)
    {
        return $query->where('ocr_status', 'completed');
    }
}
```

### RecurringExpense Model

**File**: `app/Models/RecurringExpense.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RecurringExpense extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category_id',
        'amount',
        'frequency',
        'description',
        'detected_at',
        'confidence_score',
        'is_confirmed',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'detected_at' => 'datetime',
        'confidence_score' => 'decimal:2',
        'is_confirmed' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
```

### AiConversation Model

**File**: `app/Models/AiConversation.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AiConversation extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'messages',
    ];

    protected $casts = [
        'messages' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function addMessage(string $role, string $content): void
    {
        $messages = $this->messages ?? [];
        $messages[] = [
            'role' => $role,
            'content' => $content,
            'timestamp' => now()->toISOString(),
        ];
        $this->messages = $messages;
        $this->save();
    }
}
```

---

## 3. Controllers

### AuthController

**File**: `app/Http/Controllers/AuthController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', Password::min(8)
                ->mixedCase()
                ->numbers()
                ->symbols()],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        // Create personal access token
        $token = $user->createToken('auth_token')->plainTextToken;

        // Copy predefined categories to user
        $this->copyPredefinedCategoriesToUser($user);

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    private function copyPredefinedCategoriesToUser(User $user): void
    {
        $predefinedCategories = \App\Models\Category::whereNull('user_id')->get();

        foreach ($predefinedCategories as $category) {
            \App\Models\Category::create([
                'user_id' => $user->id,
                'name' => $category->name,
                'type' => $category->type,
                'icon' => $category->icon,
                'color' => $category->color,
                'is_predefined' => true,
            ]);
        }
    }
}
```

### TransactionController

**File**: `app/Http/Controllers/TransactionController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Services\TransactionService;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function __construct(
        private TransactionService $transactionService
    ) {}

    public function index(Request $request)
    {
        $transactions = $this->transactionService->list(
            user: $request->user(),
            filters: $request->only(['type', 'category_id', 'from_date', 'to_date']),
            perPage: $request->input('per_page', 50)
        );

        return TransactionResource::collection($transactions);
    }

    public function store(StoreTransactionRequest $request)
    {
        $transaction = $this->transactionService->create(
            user: $request->user(),
            data: $request->validated()
        );

        return new TransactionResource($transaction);
    }

    public function show(Request $request, int $id)
    {
        $transaction = $this->transactionService->findById(
            id: $id,
            userId: $request->user()->id
        );

        return new TransactionResource($transaction);
    }

    public function update(UpdateTransactionRequest $request, int $id)
    {
        $transaction = $this->transactionService->update(
            id: $id,
            userId: $request->user()->id,
            data: $request->validated()
        );

        return new TransactionResource($transaction);
    }

    public function destroy(Request $request, int $id)
    {
        $this->transactionService->delete(
            id: $id,
            userId: $request->user()->id
        );

        return response()->json([
            'message' => 'Transaction deleted successfully',
        ]);
    }
}
```

---

## 4. Services

### TransactionService

**File**: `app/Services/TransactionService.php`

```php
<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\User;
use App\Repositories\TransactionRepository;
use Illuminate\Pagination\LengthAwarePaginator;

class TransactionService
{
    public function __construct(
        private TransactionRepository $transactionRepository
    ) {}

    public function list(User $user, array $filters = [], int $perPage = 50): LengthAwarePaginator
    {
        return $this->transactionRepository->paginate($user->id, $filters, $perPage);
    }

    public function create(User $user, array $data): Transaction
    {
        $data['user_id'] = $user->id;
        $data['date'] = $data['date'] ?? now()->toDateString();

        return $this->transactionRepository->create($data);
    }

    public function findById(int $id, int $userId): ?Transaction
    {
        return $this->transactionRepository->findByIdAndUser($id, $userId);
    }

    public function update(int $id, int $userId, array $data): Transaction
    {
        $transaction = $this->findById($id, $userId);

        if (!$transaction) {
            throw new \Exception('Transaction not found');
        }

        return $this->transactionRepository->update($transaction, $data);
    }

    public function delete(int $id, int $userId): bool
    {
        $transaction = $this->findById($id, $userId);

        if (!$transaction) {
            throw new \Exception('Transaction not found');
        }

        return $this->transactionRepository->delete($transaction);
    }

    public function getByDateRange(User $user, string $startDate, string $endDate, ?string $type = null)
    {
        return $this->transactionRepository->getByDateRange(
            userId: $user->id,
            startDate: $startDate,
            endDate: $endDate,
            type: $type
        );
    }

    public function getTotalByCategory(User $user, string $startDate, string $endDate, string $type = 'expense')
    {
        return $this->transactionRepository->getTotalByCategory(
            userId: $user->id,
            startDate: $startDate,
            endDate: $endDate,
            type: $type
        );
    }
}
```

### ClaudeService

**File**: `app/Services/ClaudeService.php`

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class ClaudeService
{
    private string $apiKey;
    private string $model;
    private string $apiUrl = 'https://api.anthropic.com/v1/messages';

    public function __construct()
    {
        $this->apiKey = config('services.claude.api_key');
        $this->model = config('services.claude.model', 'claude-3-5-sonnet-20241022');
    }

    public function sendMessage(array $messages, array $tools = [], string $systemPrompt = null): array
    {
        $payload = [
            'model' => $this->model,
            'max_tokens' => 4096,
            'messages' => $messages,
        ];

        if ($systemPrompt) {
            $payload['system'] = $systemPrompt;
        }

        if (!empty($tools)) {
            $payload['tools'] = $tools;
        }

        $response = Http::withHeaders([
            'x-api-key' => $this->apiKey,
            'anthropic-version' => '2023-06-01',
            'content-type' => 'application/json',
        ])->post($this->apiUrl, $payload);

        if ($response->failed()) {
            throw new \Exception('Claude API request failed: ' . $response->body());
        }

        return $response->json();
    }

    public function getSystemPrompt(): string
    {
        return <<<PROMPT
You are a personal finance assistant helping users manage their money. You have access to their transaction history, budgets, and spending patterns.

Your role is to:
1. Help users add transactions through natural conversation
2. Answer questions about their spending
3. Provide insights and recommendations
4. Detect patterns and anomalies
5. Generate actionable optimization plans

Always be:
- Precise with numbers and include currency symbols
- Supportive and non-judgmental about spending habits
- Focused on actionable advice
- Clear about data sources and time periods
- Specific with dates and amounts

When users ask about transactions, always provide specific amounts, dates, and categories.
Format monetary amounts clearly (e.g., "$45.50" not "45.5").
PROMPT;
    }

    public function getToolDefinitions(): array
    {
        return [
            [
                'name' => 'create_transaction',
                'description' => 'Create a new expense or income transaction',
                'input_schema' => [
                    'type' => 'object',
                    'properties' => [
                        'amount' => [
                            'type' => 'number',
                            'description' => 'Transaction amount (positive number)',
                        ],
                        'type' => [
                            'type' => 'string',
                            'enum' => ['expense', 'income'],
                            'description' => 'Transaction type',
                        ],
                        'description' => [
                            'type' => 'string',
                            'description' => 'Transaction description',
                        ],
                        'date' => [
                            'type' => 'string',
                            'description' => 'Transaction date in YYYY-MM-DD format. If not specified, use today.',
                        ],
                        'category_name' => [
                            'type' => 'string',
                            'description' => 'Category name (e.g., "Food & Dining", "Transportation")',
                        ],
                    ],
                    'required' => ['amount', 'type', 'description', 'category_name'],
                ],
            ],
            [
                'name' => 'list_transactions',
                'description' => 'List transactions with optional filtering',
                'input_schema' => [
                    'type' => 'object',
                    'properties' => [
                        'type' => [
                            'type' => 'string',
                            'enum' => ['expense', 'income'],
                            'description' => 'Filter by transaction type',
                        ],
                        'category_name' => [
                            'type' => 'string',
                            'description' => 'Filter by category name',
                        ],
                        'from_date' => [
                            'type' => 'string',
                            'description' => 'Start date (YYYY-MM-DD)',
                        ],
                        'to_date' => [
                            'type' => 'string',
                            'description' => 'End date (YYYY-MM-DD)',
                        ],
                        'limit' => [
                            'type' => 'integer',
                            'description' => 'Maximum number of results (default: 50)',
                        ],
                    ],
                ],
            ],
            [
                'name' => 'summarize_month',
                'description' => 'Get financial summary for a specific month',
                'input_schema' => [
                    'type' => 'object',
                    'properties' => [
                        'month' => [
                            'type' => 'integer',
                            'description' => 'Month (1-12)',
                        ],
                        'year' => [
                            'type' => 'integer',
                            'description' => 'Year (YYYY)',
                        ],
                    ],
                    'required' => ['month', 'year'],
                ],
            ],
            [
                'name' => 'detect_overspending',
                'description' => 'Analyze spending patterns to detect overspending categories',
                'input_schema' => [
                    'type' => 'object',
                    'properties' => [
                        'month' => [
                            'type' => 'integer',
                            'description' => 'Month to analyze (1-12)',
                        ],
                        'year' => [
                            'type' => 'integer',
                            'description' => 'Year to analyze (YYYY)',
                        ],
                    ],
                ],
            ],
            [
                'name' => 'detect_recurring_expenses',
                'description' => 'Identify recurring expenses from transaction history',
                'input_schema' => [
                    'type' => 'object',
                    'properties' => [
                        'lookback_months' => [
                            'type' => 'integer',
                            'description' => 'Number of months to analyze (default: 6)',
                        ],
                    ],
                ],
            ],
            [
                'name' => 'generate_optimization_plan',
                'description' => 'Generate personalized financial optimization recommendations based on spending history',
                'input_schema' => [
                    'type' => 'object',
                    'properties' => [],
                ],
            ],
        ];
    }
}
```

---

## 5. Repositories

### TransactionRepository

**File**: `app/Repositories/TransactionRepository.php`

```php
<?php

namespace App\Repositories;

use App\Models\Transaction;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class TransactionRepository
{
    public function paginate(int $userId, array $filters = [], int $perPage = 50): LengthAwarePaginator
    {
        $query = Transaction::with('category')
            ->where('user_id', $userId);

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['from_date'])) {
            $query->where('date', '>=', $filters['from_date']);
        }

        if (isset($filters['to_date'])) {
            $query->where('date', '<=', $filters['to_date']);
        }

        return $query->orderBy('date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
    }

    public function create(array $data): Transaction
    {
        return Transaction::create($data);
    }

    public function findByIdAndUser(int $id, int $userId): ?Transaction
    {
        return Transaction::with('category', 'attachments')
            ->where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    public function update(Transaction $transaction, array $data): Transaction
    {
        $transaction->update($data);
        return $transaction->fresh(['category', 'attachments']);
    }

    public function delete(Transaction $transaction): bool
    {
        return $transaction->delete();
    }

    public function getByDateRange(int $userId, string $startDate, string $endDate, ?string $type = null)
    {
        $query = Transaction::with('category')
            ->where('user_id', $userId)
            ->whereBetween('date', [$startDate, $endDate]);

        if ($type) {
            $query->where('type', $type);
        }

        return $query->orderBy('date', 'desc')->get();
    }

    public function getTotalByCategory(int $userId, string $startDate, string $endDate, string $type = 'expense')
    {
        return Transaction::select('category_id', DB::raw('SUM(amount) as total'))
            ->with('category')
            ->where('user_id', $userId)
            ->where('type', $type)
            ->whereBetween('date', [$startDate, $endDate])
            ->groupBy('category_id')
            ->orderBy('total', 'desc')
            ->get();
    }
}
```

---

## 6. Request Validation

### StoreTransactionRequest

**File**: `app/Http/Requests/StoreTransactionRequest.php`

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:0.01', 'max:999999999.99'],
            'type' => ['required', 'in:expense,income'],
            'description' => ['nullable', 'string', 'max:1000'],
            'date' => ['nullable', 'date', 'before_or_equal:today'],
            'category_id' => ['required', 'exists:categories,id'],
            'source' => ['nullable', 'in:manual,ocr,bank_import,ai_chat'],
        ];
    }

    public function messages(): array
    {
        return [
            'amount.required' => 'Transaction amount is required',
            'amount.min' => 'Amount must be at least 0.01',
            'type.required' => 'Transaction type is required',
            'type.in' => 'Transaction type must be either expense or income',
            'category_id.required' => 'Category is required',
            'category_id.exists' => 'Selected category does not exist',
        ];
    }
}
```

---

## 7. API Resources

### TransactionResource

**File**: `app/Http/Resources/TransactionResource.php`

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'amount' => number_format($this->amount, 2, '.', ''),
            'type' => $this->type,
            'description' => $this->description,
            'date' => $this->date->format('Y-m-d'),
            'category' => $this->when($this->category, [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
                'icon' => $this->category?->icon,
                'color' => $this->category?->color,
            ]),
            'source' => $this->source,
            'metadata' => $this->metadata,
            'attachments' => AttachmentResource::collection($this->whenLoaded('attachments')),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
```

---

**Continue in next file for Jobs, Chat, and Analytics implementation...**

