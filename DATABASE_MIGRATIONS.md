# Database Migrations - FinanceChat

This document contains all Laravel migration files for the FinanceChat application.

## Migration Files

Place these files in: `financechat-backend/database/migrations/`

---

## 1. Create Users Table

**Filename**: `2024_01_01_000001_create_users_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

---

## 2. Create Categories Table

**Filename**: `2024_01_01_000002_create_categories_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('name');
            $table->enum('type', ['expense', 'income']);
            $table->boolean('is_predefined')->default(false);
            $table->string('icon', 50)->nullable();
            $table->string('color', 7)->nullable();
            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'type']);
            $table->unique(['user_id', 'name', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};
```

---

## 3. Create Transactions Table

**Filename**: `2024_01_01_000003_create_transactions_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')->nullable()->constrained()->onDelete('set null');
            $table->decimal('amount', 15, 2);
            $table->enum('type', ['expense', 'income']);
            $table->text('description')->nullable();
            $table->date('date');
            $table->string('source', 50)->default('manual'); // manual, ocr, bank_import, ai_chat
            $table->jsonb('metadata')->nullable();
            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'date']);
            $table->index(['user_id', 'category_id']);
            $table->index('source');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
```

---

## 4. Create Attachments Table

**Filename**: `2024_01_01_000004_create_attachments_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transaction_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('file_path', 500);
            $table->string('file_type', 50); // receipt, invoice, statement
            $table->integer('file_size')->nullable();
            $table->enum('ocr_status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->jsonb('ocr_text')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('transaction_id');
            $table->index('ocr_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attachments');
    }
};
```

---

## 5. Create Budgets Table

**Filename**: `2024_01_01_000005_create_budgets_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budgets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->integer('month'); // 1-12
            $table->integer('year'); // YYYY
            $table->decimal('amount', 15, 2);
            $table->timestamps();

            // Constraints
            $table->unique(['user_id', 'category_id', 'month', 'year']);
            $table->index(['user_id', 'year', 'month']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};
```

---

## 6. Create Recurring Expenses Table

**Filename**: `2024_01_01_000006_create_recurring_expenses_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recurring_expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')->nullable()->constrained()->onDelete('set null');
            $table->decimal('amount', 15, 2);
            $table->enum('frequency', ['weekly', 'monthly', 'yearly'])->default('monthly');
            $table->text('description')->nullable();
            $table->timestamp('detected_at')->useCurrent();
            $table->decimal('confidence_score', 3, 2)->nullable(); // 0.00 to 1.00
            $table->boolean('is_confirmed')->default(false);
            $table->timestamps();

            // Indexes
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recurring_expenses');
    }
};
```

---

## 7. Create AI Conversations Table

**Filename**: `2024_01_01_000007_create_ai_conversations_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->jsonb('messages')->default('[]');
            $table->timestamps();

            // Indexes
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_conversations');
    }
};
```

---

## 8. Create Personal Access Tokens Table (Laravel Sanctum)

**Filename**: `2024_01_01_000008_create_personal_access_tokens_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();
            $table->morphs('tokenable');
            $table->string('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('personal_access_tokens');
    }
};
```

---

## 9. Create Jobs Table (for Queue)

**Filename**: `2024_01_01_000009_create_jobs_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->string('queue')->index();
            $table->longText('payload');
            $table->unsignedTinyInteger('attempts');
            $table->unsignedInteger('reserved_at')->nullable();
            $table->unsignedInteger('available_at');
            $table->unsignedInteger('created_at');
        });

        Schema::create('failed_jobs', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->text('connection');
            $table->text('queue');
            $table->longText('payload');
            $table->longText('exception');
            $table->timestamp('failed_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jobs');
        Schema::dropIfExists('failed_jobs');
    }
};
```

---

## Running Migrations

```bash
# Run all migrations
php artisan migrate

# Run with seeding
php artisan migrate --seed

# Rollback last migration
php artisan migrate:rollback

# Rollback all migrations
php artisan migrate:reset

# Rollback and re-run all migrations
php artisan migrate:refresh

# Check migration status
php artisan migrate:status
```

---

## Database Seeder

**Filename**: `database/seeders/DatabaseSeeder.php`

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            CategorySeeder::class,
        ]);
    }
}
```

---

## Category Seeder

**Filename**: `database/seeders/CategorySeeder.php`

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $predefinedCategories = [
            // Expense categories
            ['name' => 'Food & Dining', 'type' => 'expense', 'icon' => 'utensils', 'color' => '#FF6B6B'],
            ['name' => 'Transportation', 'type' => 'expense', 'icon' => 'car', 'color' => '#4ECDC4'],
            ['name' => 'Housing', 'type' => 'expense', 'icon' => 'home', 'color' => '#45B7D1'],
            ['name' => 'Utilities', 'type' => 'expense', 'icon' => 'bolt', 'color' => '#FFA07A'],
            ['name' => 'Healthcare', 'type' => 'expense', 'icon' => 'heartbeat', 'color' => '#98D8C8'],
            ['name' => 'Entertainment', 'type' => 'expense', 'icon' => 'film', 'color' => '#F7B731'],
            ['name' => 'Shopping', 'type' => 'expense', 'icon' => 'shopping-bag', 'color' => '#5F27CD'],
            ['name' => 'Education', 'type' => 'expense', 'icon' => 'graduation-cap', 'color' => '#00D2D3'],
            ['name' => 'Insurance', 'type' => 'expense', 'icon' => 'shield-alt', 'color' => '#1DD1A1'],
            ['name' => 'Personal Care', 'type' => 'expense', 'icon' => 'spa', 'color' => '#EE5A6F'],
            ['name' => 'Travel', 'type' => 'expense', 'icon' => 'plane', 'color' => '#00B894'],
            ['name' => 'Subscriptions', 'type' => 'expense', 'icon' => 'sync-alt', 'color' => '#6C5CE7'],
            ['name' => 'Other Expenses', 'type' => 'expense', 'icon' => 'ellipsis-h', 'color' => '#95A5A6'],

            // Income categories
            ['name' => 'Salary', 'type' => 'income', 'icon' => 'briefcase', 'color' => '#00B894'],
            ['name' => 'Freelance', 'type' => 'income', 'icon' => 'laptop', 'color' => '#6C5CE7'],
            ['name' => 'Investment', 'type' => 'income', 'icon' => 'chart-line', 'color' => '#FDCB6E'],
            ['name' => 'Gift', 'type' => 'income', 'icon' => 'gift', 'color' => '#E17055'],
            ['name' => 'Other Income', 'type' => 'income', 'icon' => 'plus-circle', 'color' => '#74B9FF'],
        ];

        foreach ($predefinedCategories as $category) {
            DB::table('categories')->insert([
                'user_id' => null, // Global predefined categories
                'name' => $category['name'],
                'type' => $category['type'],
                'icon' => $category['icon'],
                'color' => $category['color'],
                'is_predefined' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
```

---

## PostgreSQL-Specific Features Used

1. **JSONB Data Type**: Used for `metadata` and `messages` columns for flexible JSON storage with indexing support
2. **Enum Types**: Implemented via CHECK constraints for `type`, `source`, `ocr_status`, `frequency`
3. **Indexes**: Strategic indexes on foreign keys and frequently queried columns
4. **Cascading Deletes**: `onDelete('cascade')` for maintaining referential integrity
5. **Unique Constraints**: Composite unique indexes for budget uniqueness

---

**Last Updated**: 2025-01-24
