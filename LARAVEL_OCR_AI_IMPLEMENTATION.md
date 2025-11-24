# OCR & AI Implementation - FinanceChat Backend

Complete implementation of OCR processing, queue jobs, chat service, and analytics.

---

## 1. Queue Jobs

### ProcessReceiptOCR Job

**File**: `app/Jobs/ProcessReceiptOCR.php`

```php
<?php

namespace App\Jobs;

use App\Models\Attachment;
use App\Services\OCRService;
use App\Services\ClaudeService;
use App\Services\TransactionService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessReceiptOCR implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 300; // 5 minutes
    public $tries = 3;

    public function __construct(
        public Attachment $attachment
    ) {}

    public function handle(
        OCRService $ocrService,
        ClaudeService $claudeService,
        TransactionService $transactionService
    ): void {
        try {
            // Update status to processing
            $this->attachment->update(['ocr_status' => 'processing']);

            // Step 1: Extract text from image/PDF using Tesseract
            $extractedText = $ocrService->extractText($this->attachment->file_path);

            if (empty($extractedText)) {
                throw new \Exception('No text could be extracted from the receipt');
            }

            // Step 2: Parse extracted text using Claude
            $parsedData = $this->parseReceiptWithClaude($claudeService, $extractedText);

            // Step 3: Save OCR results
            $this->attachment->update([
                'ocr_text' => [
                    'raw' => $extractedText,
                    'parsed' => $parsedData,
                ],
            ]);

            // Step 4: Create transaction if parsing was successful
            if ($parsedData && isset($parsedData['amount'], $parsedData['description'])) {
                $transaction = $transactionService->create(
                    user: $this->attachment->transaction->user ?? \App\Models\User::find($parsedData['user_id']),
                    data: [
                        'amount' => $parsedData['amount'],
                        'type' => $parsedData['type'] ?? 'expense',
                        'description' => $parsedData['description'],
                        'date' => $parsedData['date'] ?? now()->toDateString(),
                        'category_id' => $parsedData['category_id'],
                        'source' => 'ocr',
                        'metadata' => [
                            'merchant' => $parsedData['merchant'] ?? null,
                            'confidence' => $parsedData['confidence'] ?? null,
                        ],
                    ]
                );

                // Link attachment to transaction
                $this->attachment->update([
                    'transaction_id' => $transaction->id,
                    'ocr_status' => 'completed',
                ]);

                Log::info('Receipt OCR completed successfully', [
                    'attachment_id' => $this->attachment->id,
                    'transaction_id' => $transaction->id,
                ]);
            } else {
                throw new \Exception('Failed to parse receipt data');
            }
        } catch (\Exception $e) {
            $this->attachment->update([
                'ocr_status' => 'failed',
                'ocr_text' => [
                    'error' => $e->getMessage(),
                ],
            ]);

            Log::error('Receipt OCR failed', [
                'attachment_id' => $this->attachment->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    private function parseReceiptWithClaude(ClaudeService $claudeService, string $extractedText): ?array
    {
        $prompt = <<<PROMPT
Parse the following receipt text and extract structured transaction data.

Receipt text:
{$extractedText}

Extract and return JSON with:
- amount: total amount (number)
- description: brief description of purchase
- merchant: merchant/store name
- date: transaction date (YYYY-MM-DD format, or null if not found)
- category: suggested category (e.g., "Food & Dining", "Shopping", etc.)
- confidence: your confidence in the extraction (0.0 to 1.0)

Return ONLY valid JSON, no other text.
PROMPT;

        $response = $claudeService->sendMessage(
            messages: [
                ['role' => 'user', 'content' => $prompt],
            ],
            systemPrompt: 'You are a receipt parsing assistant. Extract transaction data from receipt text and return only valid JSON.'
        );

        if (isset($response['content'][0]['text'])) {
            $jsonText = $response['content'][0]['text'];
            // Remove markdown code blocks if present
            $jsonText = preg_replace('/```json\s*|\s*```/', '', $jsonText);
            $parsed = json_decode($jsonText, true);

            if (json_last_error() === JSON_ERROR_NONE) {
                return $parsed;
            }
        }

        return null;
    }
}
```

---

### ProcessBankStatement Job

**File**: `app/Jobs/ProcessBankStatement.php`

```php
<?php

namespace App\Jobs;

use App\Models\Attachment;
use App\Models\User;
use App\Services\OCRService;
use App\Services\ClaudeService;
use App\Services\TransactionService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessBankStatement implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 600; // 10 minutes
    public $tries = 2;

    public function __construct(
        public Attachment $attachment,
        public int $userId,
        public int $month,
        public int $year
    ) {}

    public function handle(
        OCRService $ocrService,
        ClaudeService $claudeService,
        TransactionService $transactionService
    ): void {
        try {
            $this->attachment->update(['ocr_status' => 'processing']);

            // Step 1: Extract text from PDF
            $extractedText = $ocrService->extractText($this->attachment->file_path);

            if (empty($extractedText)) {
                throw new \Exception('No text could be extracted from bank statement');
            }

            // Step 2: Parse bank statement using Claude
            $transactions = $this->parseBankStatementWithClaude($claudeService, $extractedText);

            if (empty($transactions)) {
                throw new \Exception('No transactions found in bank statement');
            }

            // Step 3: Create all transactions
            $user = User::findOrFail($this->userId);
            $createdCount = 0;

            foreach ($transactions as $txData) {
                try {
                    $transactionService->create(
                        user: $user,
                        data: [
                            'amount' => abs($txData['amount']),
                            'type' => $txData['type'],
                            'description' => $txData['description'],
                            'date' => $txData['date'],
                            'category_id' => $txData['category_id'],
                            'source' => 'bank_import',
                            'metadata' => [
                                'bank_reference' => $txData['reference'] ?? null,
                            ],
                        ]
                    );
                    $createdCount++;
                } catch (\Exception $e) {
                    Log::warning('Failed to create transaction from bank statement', [
                        'transaction_data' => $txData,
                        'error' => $e->getMessage(),
                    ]);
                }
            }

            $this->attachment->update([
                'ocr_status' => 'completed',
                'ocr_text' => [
                    'raw' => $extractedText,
                    'transactions_found' => count($transactions),
                    'transactions_created' => $createdCount,
                ],
            ]);

            Log::info('Bank statement processed successfully', [
                'attachment_id' => $this->attachment->id,
                'transactions_created' => $createdCount,
            ]);
        } catch (\Exception $e) {
            $this->attachment->update([
                'ocr_status' => 'failed',
                'ocr_text' => [
                    'error' => $e->getMessage(),
                ],
            ]);

            Log::error('Bank statement processing failed', [
                'attachment_id' => $this->attachment->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    private function parseBankStatementWithClaude(ClaudeService $claudeService, string $extractedText): array
    {
        $prompt = <<<PROMPT
Parse this bank statement and extract all transactions.

Bank statement text:
{$extractedText}

For each transaction, extract:
- date: transaction date (YYYY-MM-DD)
- description: transaction description
- amount: amount (positive number)
- type: "expense" or "income" (debits are expenses, credits are income)
- category: suggested category name
- reference: any reference number (optional)

Return a JSON array of transactions. Return ONLY valid JSON, no other text.

Example format:
[
  {
    "date": "2025-01-15",
    "description": "Amazon purchase",
    "amount": 45.99,
    "type": "expense",
    "category": "Shopping",
    "reference": "REF123"
  }
]
PROMPT;

        $response = $claudeService->sendMessage(
            messages: [
                ['role' => 'user', 'content' => $prompt],
            ],
            systemPrompt: 'You are a bank statement parser. Extract all transactions and return only valid JSON array.'
        );

        if (isset($response['content'][0]['text'])) {
            $jsonText = $response['content'][0]['text'];
            $jsonText = preg_replace('/```json\s*|\s*```/', '', $jsonText);
            $parsed = json_decode($jsonText, true);

            if (json_last_error() === JSON_ERROR_NONE && is_array($parsed)) {
                // Resolve category names to IDs
                $user = User::findOrFail($this->userId);
                return array_map(function ($tx) use ($user) {
                    $category = \App\Models\Category::forUser($user->id)
                        ->where('name', 'ILIKE', $tx['category'])
                        ->first();

                    $tx['category_id'] = $category?->id ?? $this->getDefaultCategoryId($user, $tx['type']);
                    return $tx;
                }, $parsed);
            }
        }

        return [];
    }

    private function getDefaultCategoryId(User $user, string $type): int
    {
        $defaultName = $type === 'expense' ? 'Other Expenses' : 'Other Income';
        $category = \App\Models\Category::forUser($user->id)
            ->where('name', $defaultName)
            ->first();

        return $category->id;
    }
}
```

---

## 2. OCR Service

**File**: `app/Services/OCRService.php`

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use thiagoalessio\TesseractOCR\TesseractOCR;

class OCRService
{
    /**
     * Extract text from image or PDF file
     */
    public function extractText(string $filePath): string
    {
        $fullPath = Storage::path($filePath);

        if (!file_exists($fullPath)) {
            throw new \Exception("File not found: {$filePath}");
        }

        // Check file type
        $mimeType = mime_content_type($fullPath);

        if (str_starts_with($mimeType, 'image/')) {
            return $this->extractFromImage($fullPath);
        } elseif ($mimeType === 'application/pdf') {
            return $this->extractFromPdf($fullPath);
        }

        throw new \Exception("Unsupported file type: {$mimeType}");
    }

    /**
     * Extract text from image using Tesseract
     */
    private function extractFromImage(string $imagePath): string
    {
        try {
            $ocr = new TesseractOCR($imagePath);
            $ocr->lang('eng');
            $text = $ocr->run();

            return trim($text);
        } catch (\Exception $e) {
            throw new \Exception("Tesseract OCR failed: " . $e->getMessage());
        }
    }

    /**
     * Extract text from PDF
     * First converts PDF to images, then runs OCR on each page
     */
    private function extractFromPdf(string $pdfPath): string
    {
        try {
            // Use Imagick to convert PDF to images
            $imagick = new \Imagick();
            $imagick->setResolution(300, 300);
            $imagick->readImage($pdfPath);

            $texts = [];
            $numberOfPages = $imagick->getNumberImages();

            for ($i = 0; $i < $numberOfPages; $i++) {
                $imagick->setIteratorIndex($i);
                $imagick->setImageFormat('png');

                // Save temporary image
                $tempImage = sys_get_temp_dir() . '/pdf_page_' . $i . '_' . uniqid() . '.png';
                $imagick->writeImage($tempImage);

                // Run OCR on image
                $pageText = $this->extractFromImage($tempImage);
                $texts[] = $pageText;

                // Clean up temp file
                @unlink($tempImage);
            }

            $imagick->clear();
            $imagick->destroy();

            return implode("\n\n--- PAGE BREAK ---\n\n", $texts);
        } catch (\Exception $e) {
            throw new \Exception("PDF extraction failed: " . $e->getMessage());
        }
    }
}
```

---

## 3. Chat Service

**File**: `app/Services/ChatService.php`

```php
<?php

namespace App\Services;

use App\Models\User;
use App\Models\AiConversation;
use App\Repositories\ConversationRepository;
use Carbon\Carbon;

class ChatService
{
    public function __construct(
        private ClaudeService $claudeService,
        private ConversationRepository $conversationRepository,
        private TransactionService $transactionService,
        private AnalyticsService $analyticsService,
        private CategoryService $categoryService
    ) {}

    public function sendMessage(User $user, string $message, ?int $conversationId = null): array
    {
        // Get or create conversation
        $conversation = $conversationId
            ? $this->conversationRepository->find($conversationId, $user->id)
            : $this->conversationRepository->create($user->id);

        // Add user message to conversation
        $conversation->addMessage('user', $message);

        // Prepare messages for Claude
        $messages = $this->formatMessagesForClaude($conversation->messages);

        // Send to Claude with tools
        $response = $this->claudeService->sendMessage(
            messages: $messages,
            tools: $this->claudeService->getToolDefinitions(),
            systemPrompt: $this->claudeService->getSystemPrompt()
        );

        // Process tool calls if any
        $toolResults = [];
        if (isset($response['content'])) {
            foreach ($response['content'] as $block) {
                if ($block['type'] === 'tool_use') {
                    $toolResult = $this->executeToolCall(
                        user: $user,
                        toolName: $block['name'],
                        toolInput: $block['input']
                    );
                    $toolResults[] = [
                        'tool' => $block['name'],
                        'input' => $block['input'],
                        'result' => $toolResult,
                    ];

                    // Add tool result to messages and get final response
                    $messages[] = ['role' => 'assistant', 'content' => $response['content']];
                    $messages[] = [
                        'role' => 'user',
                        'content' => [
                            [
                                'type' => 'tool_result',
                                'tool_use_id' => $block['id'],
                                'content' => json_encode($toolResult),
                            ],
                        ],
                    ];
                }
            }
        }

        // Get final response if there were tool calls
        if (!empty($toolResults)) {
            $response = $this->claudeService->sendMessage(
                messages: $messages,
                systemPrompt: $this->claudeService->getSystemPrompt()
            );
        }

        // Extract text response
        $assistantMessage = '';
        foreach ($response['content'] as $block) {
            if ($block['type'] === 'text') {
                $assistantMessage = $block['text'];
                break;
            }
        }

        // Save assistant response
        $conversation->addMessage('assistant', $assistantMessage);

        return [
            'conversation_id' => $conversation->id,
            'response' => $assistantMessage,
            'tool_calls' => $toolResults,
        ];
    }

    private function executeToolCall(User $user, string $toolName, array $input): array
    {
        return match ($toolName) {
            'create_transaction' => $this->handleCreateTransaction($user, $input),
            'list_transactions' => $this->handleListTransactions($user, $input),
            'summarize_month' => $this->handleSummarizeMonth($user, $input),
            'detect_overspending' => $this->handleDetectOverspending($user, $input),
            'detect_recurring_expenses' => $this->handleDetectRecurring($user, $input),
            'generate_optimization_plan' => $this->handleOptimizationPlan($user, $input),
            default => ['error' => 'Unknown tool'],
        };
    }

    private function handleCreateTransaction(User $user, array $input): array
    {
        try {
            // Find category by name
            $category = $this->categoryService->findByName($user, $input['category_name'], $input['type']);

            if (!$category) {
                return ['error' => "Category '{$input['category_name']}' not found"];
            }

            $transaction = $this->transactionService->create(
                user: $user,
                data: [
                    'amount' => $input['amount'],
                    'type' => $input['type'],
                    'description' => $input['description'],
                    'date' => $input['date'] ?? now()->toDateString(),
                    'category_id' => $category->id,
                    'source' => 'ai_chat',
                ]
            );

            return [
                'success' => true,
                'transaction' => [
                    'id' => $transaction->id,
                    'amount' => $transaction->amount,
                    'description' => $transaction->description,
                    'category' => $category->name,
                    'date' => $transaction->date->format('Y-m-d'),
                ],
            ];
        } catch (\Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }

    private function handleListTransactions(User $user, array $input): array
    {
        $filters = [];

        if (isset($input['type'])) {
            $filters['type'] = $input['type'];
        }

        if (isset($input['from_date'])) {
            $filters['from_date'] = $input['from_date'];
        }

        if (isset($input['to_date'])) {
            $filters['to_date'] = $input['to_date'];
        }

        if (isset($input['category_name'])) {
            $category = $this->categoryService->findByName($user, $input['category_name']);
            if ($category) {
                $filters['category_id'] = $category->id;
            }
        }

        $transactions = $this->transactionService->list(
            user: $user,
            filters: $filters,
            perPage: $input['limit'] ?? 50
        );

        return [
            'total' => $transactions->total(),
            'transactions' => $transactions->items(),
        ];
    }

    private function handleSummarizeMonth(User $user, array $input): array
    {
        $month = $input['month'];
        $year = $input['year'];

        return $this->analyticsService->getMonthSummary($user, $month, $year);
    }

    private function handleDetectOverspending(User $user, array $input): array
    {
        $month = $input['month'] ?? now()->month;
        $year = $input['year'] ?? now()->year;

        return $this->analyticsService->detectOverspending($user, $month, $year);
    }

    private function handleDetectRecurring(User $user, array $input): array
    {
        $lookbackMonths = $input['lookback_months'] ?? 6;

        return $this->analyticsService->detectRecurringExpenses($user, $lookbackMonths);
    }

    private function handleOptimizationPlan(User $user, array $input): array
    {
        return $this->analyticsService->generateOptimizationPlan($user);
    }

    private function formatMessagesForClaude(array $messages): array
    {
        return array_map(function ($msg) {
            return [
                'role' => $msg['role'],
                'content' => $msg['content'],
            ];
        }, $messages);
    }
}
```

---

## 4. Analytics Service

**File**: `app/Services/AnalyticsService.php`

```php
<?php

namespace App\Services;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class AnalyticsService
{
    public function __construct(
        private TransactionService $transactionService
    ) {}

    public function getMonthSummary(User $user, int $month, int $year): array
    {
        $startDate = Carbon::create($year, $month, 1)->startOfMonth();
        $endDate = $startDate->copy()->endOfMonth();

        $expenses = $this->transactionService->getByDateRange(
            user: $user,
            startDate: $startDate->toDateString(),
            endDate: $endDate->toDateString(),
            type: 'expense'
        );

        $incomes = $this->transactionService->getByDateRange(
            user: $user,
            startDate: $startDate->toDateString(),
            endDate: $endDate->toDateString(),
            type: 'income'
        );

        $totalExpenses = $expenses->sum('amount');
        $totalIncome = $incomes->sum('amount');
        $net = $totalIncome - $totalExpenses;
        $savingsRate = $totalIncome > 0 ? ($net / $totalIncome) * 100 : 0;

        $expensesByCategory = $this->transactionService->getTotalByCategory(
            user: $user,
            startDate: $startDate->toDateString(),
            endDate: $endDate->toDateString(),
            type: 'expense'
        );

        return [
            'period' => [
                'month' => $month,
                'year' => $year,
            ],
            'summary' => [
                'total_income' => number_format($totalIncome, 2, '.', ''),
                'total_expenses' => number_format($totalExpenses, 2, '.', ''),
                'net' => number_format($net, 2, '.', ''),
                'savings_rate' => round($savingsRate, 1),
            ],
            'expenses_by_category' => $expensesByCategory->map(fn($item) => [
                'category' => $item->category->name,
                'amount' => number_format($item->total, 2, '.', ''),
                'percentage' => $totalExpenses > 0 ? round(($item->total / $totalExpenses) * 100, 1) : 0,
            ])->toArray(),
        ];
    }

    public function detectOverspending(User $user, int $month, int $year): array
    {
        // Get current month spending by category
        $currentStart = Carbon::create($year, $month, 1)->startOfMonth();
        $currentEnd = $currentStart->copy()->endOfMonth();

        $currentSpending = $this->transactionService->getTotalByCategory(
            user: $user,
            startDate: $currentStart->toDateString(),
            endDate: $currentEnd->toDateString(),
            type: 'expense'
        );

        // Get average spending for previous 3 months
        $previousMonthsAvg = [];
        for ($i = 1; $i <= 3; $i++) {
            $prevStart = $currentStart->copy()->subMonths($i)->startOfMonth();
            $prevEnd = $prevStart->copy()->endOfMonth();

            $prevSpending = $this->transactionService->getTotalByCategory(
                user: $user,
                startDate: $prevStart->toDateString(),
                endDate: $prevEnd->toDateString(),
                type: 'expense'
            );

            foreach ($prevSpending as $item) {
                $categoryId = $item->category_id;
                if (!isset($previousMonthsAvg[$categoryId])) {
                    $previousMonthsAvg[$categoryId] = [];
                }
                $previousMonthsAvg[$categoryId][] = $item->total;
            }
        }

        // Calculate averages
        $averages = [];
        foreach ($previousMonthsAvg as $categoryId => $amounts) {
            $averages[$categoryId] = array_sum($amounts) / count($amounts);
        }

        // Detect overspending (>20% above average)
        $overspending = [];
        foreach ($currentSpending as $item) {
            $categoryId = $item->category_id;
            $currentAmount = $item->total;
            $average = $averages[$categoryId] ?? 0;

            if ($average > 0 && $currentAmount > $average * 1.2) {
                $deviation = (($currentAmount - $average) / $average) * 100;
                $overspending[] = [
                    'category' => $item->category->name,
                    'current_month' => number_format($currentAmount, 2, '.', ''),
                    'average' => number_format($average, 2, '.', ''),
                    'deviation_percentage' => round($deviation, 1),
                    'recommendation' => $this->getOverspendingRecommendation($item->category->name, $deviation),
                ];
            }
        }

        return ['overspending_categories' => $overspending];
    }

    public function detectRecurringExpenses(User $user, int $lookbackMonths = 6): array
    {
        $startDate = now()->subMonths($lookbackMonths)->startOfMonth();
        $endDate = now()->endOfMonth();

        $transactions = $this->transactionService->getByDateRange(
            user: $user,
            startDate: $startDate->toDateString(),
            endDate: $endDate->toDateString(),
            type: 'expense'
        );

        // Group by similar descriptions and amounts
        $grouped = [];
        foreach ($transactions as $tx) {
            $key = $this->normalizeDescription($tx->description);
            $amountKey = round($tx->amount / 5) * 5; // Group by $5 increments

            $groupKey = $key . '_' . $amountKey;

            if (!isset($grouped[$groupKey])) {
                $grouped[$groupKey] = [];
            }

            $grouped[$groupKey][] = $tx;
        }

        // Find recurring patterns (3+ occurrences)
        $recurring = [];
        foreach ($grouped as $groupKey => $txs) {
            if (count($txs) >= 3) {
                // Calculate average days between transactions
                $dates = collect($txs)->pluck('date')->sort()->values();
                $intervals = [];

                for ($i = 1; $i < $dates->count(); $i++) {
                    $intervals[] = $dates[$i]->diffInDays($dates[$i - 1]);
                }

                $avgInterval = array_sum($intervals) / count($intervals);
                $frequency = $this->determineFrequency($avgInterval);

                if ($frequency) {
                    $avgAmount = collect($txs)->avg('amount');
                    $recurring[] = [
                        'description' => $txs[0]->description,
                        'amount' => number_format($avgAmount, 2, '.', ''),
                        'frequency' => $frequency,
                        'category' => $txs[0]->category->name,
                        'confidence' => $this->calculateConfidence(count($txs), $intervals),
                        'occurrences' => collect($txs)->pluck('date')->map(fn($d) => $d->format('Y-m-d'))->toArray(),
                    ];
                }
            }
        }

        return ['recurring_expenses' => $recurring];
    }

    public function generateOptimizationPlan(User $user): array
    {
        $currentMonth = now()->month;
        $currentYear = now()->year;

        // Get current month summary
        $summary = $this->getMonthSummary($user, $currentMonth, $currentYear);

        // Detect overspending
        $overspending = $this->detectOverspending($user, $currentMonth, $currentYear);

        // Detect recurring expenses
        $recurring = $this->detectRecurringExpenses($user);

        // Generate recommendations
        $recommendations = [];
        $totalPotentialSavings = 0;

        // 1. Overspending categories
        foreach ($overspending['overspending_categories'] as $category) {
            $potentialSaving = (float)$category['current_month'] * 0.2; // 20% reduction
            $totalPotentialSavings += $potentialSaving;

            $recommendations[] = [
                'category' => $category['category'],
                'current_spending' => $category['current_month'],
                'action' => $category['recommendation'],
                'potential_savings' => number_format($potentialSaving, 2, '.', ''),
                'priority' => 'high',
            ];
        }

        // 2. Recurring expenses analysis
        $subscriptionTotal = 0;
        foreach ($recurring['recurring_expenses'] as $expense) {
            if (stripos($expense['description'], 'subscription') !== false || $expense['category'] === 'Subscriptions') {
                $subscriptionTotal += (float)$expense['amount'];
            }
        }

        if ($subscriptionTotal > 50) {
            $recommendations[] = [
                'category' => 'Subscriptions',
                'current_spending' => number_format($subscriptionTotal, 2, '.', ''),
                'action' => 'Review and cancel unused subscriptions',
                'potential_savings' => number_format($subscriptionTotal * 0.3, 2, '.', ''),
                'priority' => 'high',
            ];
            $totalPotentialSavings += $subscriptionTotal * 0.3;
        }

        return [
            'optimization_plan' => [
                'potential_savings' => number_format($totalPotentialSavings, 2, '.', ''),
                'recommendations' => $recommendations,
            ],
        ];
    }

    private function getOverspendingRecommendation(string $category, float $deviation): string
    {
        return match (true) {
            str_contains(strtolower($category), 'food') || str_contains(strtolower($category), 'dining') =>
                "Your {$category} spending is {$deviation}% above average. Consider meal planning and reducing restaurant visits.",
            str_contains(strtolower($category), 'entertainment') =>
                "Entertainment spending is elevated. Look for free or low-cost alternatives.",
            str_contains(strtolower($category), 'shopping') =>
                "Shopping expenses are higher than usual. Consider implementing a 24-hour rule before purchases.",
            default =>
                "Your {$category} spending is {$deviation}% above average. Review recent transactions in this category.",
        };
    }

    private function normalizeDescription(string $description): string
    {
        // Remove numbers, special chars, extra spaces
        $normalized = preg_replace('/[0-9]+/', '', $description);
        $normalized = preg_replace('/[^a-zA-Z\s]/', '', $normalized);
        $normalized = preg_replace('/\s+/', ' ', $normalized);
        return strtolower(trim($normalized));
    }

    private function determineFrequency(float $avgDays): ?string
    {
        return match (true) {
            $avgDays >= 25 && $avgDays <= 35 => 'monthly',
            $avgDays >= 5 && $avgDays <= 9 => 'weekly',
            $avgDays >= 350 && $avgDays <= 380 => 'yearly',
            default => null,
        };
    }

    private function calculateConfidence(int $occurrences, array $intervals): float
    {
        $consistency = 1 - (std_dev($intervals) / (array_sum($intervals) / count($intervals)));
        $frequencyScore = min($occurrences / 6, 1); // 6+ occurrences = max score

        return round(($consistency * 0.6 + $frequencyScore * 0.4), 2);
    }
}

// Helper function
function std_dev(array $values): float
{
    $count = count($values);
    if ($count < 2) return 0;

    $mean = array_sum($values) / $count;
    $variance = array_sum(array_map(fn($x) => pow($x - $mean, 2), $values)) / $count;

    return sqrt($variance);
}
```

---

## 5. Upload Controller

**File**: `app/Http/Controllers/UploadController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Jobs\ProcessBankStatement;
use App\Jobs\ProcessReceiptOCR;
use App\Models\Attachment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UploadController extends Controller
{
    public function uploadReceipt(Request $request)
    {
        $request->validate([
            'file' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:10240'], // 10MB
        ]);

        $file = $request->file('file');
        $path = $file->store('receipts', 'private');

        $attachment = Attachment::create([
            'file_path' => $path,
            'file_type' => 'receipt',
            'file_size' => $file->getSize(),
            'ocr_status' => 'pending',
        ]);

        // Dispatch OCR job
        ProcessReceiptOCR::dispatch($attachment);

        return response()->json([
            'attachment_id' => $attachment->id,
            'status' => 'processing',
            'message' => 'Receipt uploaded and queued for processing',
        ], 202);
    }

    public function uploadBankStatement(Request $request)
    {
        $request->validate([
            'file' => ['required', 'file', 'mimes:pdf', 'max:10240'], // 10MB
            'month' => ['required', 'integer', 'min:1', 'max:12'],
            'year' => ['required', 'integer', 'min:2000', 'max:2100'],
        ]);

        $file = $request->file('file');
        $path = $file->store('bank-statements', 'private');

        $attachment = Attachment::create([
            'file_path' => $path,
            'file_type' => 'statement',
            'file_size' => $file->getSize(),
            'ocr_status' => 'pending',
        ]);

        // Dispatch bank statement processing job
        ProcessBankStatement::dispatch(
            attachment: $attachment,
            userId: $request->user()->id,
            month: $request->input('month'),
            year: $request->input('year')
        );

        return response()->json([
            'job_id' => $attachment->id,
            'status' => 'processing',
            'message' => 'Bank statement uploaded and queued for processing',
        ], 202);
    }

    public function checkStatus(Request $request, int $attachmentId)
    {
        $attachment = Attachment::findOrFail($attachmentId);

        $response = [
            'attachment_id' => $attachment->id,
            'status' => $attachment->ocr_status,
        ];

        if ($attachment->ocr_status === 'completed' && $attachment->transaction_id) {
            $response['transaction'] = [
                'id' => $attachment->transaction->id,
                'amount' => $attachment->transaction->amount,
                'description' => $attachment->transaction->description,
                'date' => $attachment->transaction->date->format('Y-m-d'),
            ];
        }

        if ($attachment->ocr_status === 'failed') {
            $response['error'] = $attachment->ocr_text['error'] ?? 'Processing failed';
        }

        return response()->json($response);
    }
}
```

---

## 6. Configuration

**File**: `config/services.php`

```php
<?php

return [
    // ... other services

    'claude' => [
        'api_key' => env('CLAUDE_API_KEY'),
        'model' => env('CLAUDE_MODEL', 'claude-3-5-sonnet-20241022'),
    ],
];
```

---

## 7. Queue Configuration

**File**: `config/queue.php`

```php
<?php

return [
    'default' => env('QUEUE_CONNECTION', 'redis'),

    'connections' => [
        'redis' => [
            'driver' => 'redis',
            'connection' => 'default',
            'queue' => env('REDIS_QUEUE', 'default'),
            'retry_after' => 600,
            'block_for' => null,
        ],
    ],
];
```

---

## 8. Running Queue Workers

```bash
# Start queue worker
php artisan queue:work redis --tries=3 --timeout=600

# Or use supervisor for production
[program:financechat-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/financechat-backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
numprocs=2
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/financechat-backend/storage/logs/worker.log
```

---

**Next: Frontend implementation (Next.js, React, TypeScript)**
