# FinanceChat - Complete Implementation Guide

Step-by-step guide to build and deploy the entire system.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Backend Setup (Laravel)](#backend-setup)
3. [Frontend Setup (Next.js)](#frontend-setup)
4. [Database Setup](#database-setup)
5. [OCR Setup](#ocr-setup)
6. [Claude API Integration](#claude-api-integration)
7. [Testing](#testing)
8. [Deployment](#deployment)

---

## 1. Prerequisites

### Required Software
- **PHP**: 8.3 or higher
- **Composer**: 2.6+
- **Node.js**: 20.x LTS
- **npm** or **yarn**: Latest
- **PostgreSQL**: 15+
- **Redis**: 7+
- **Tesseract OCR**: 5+
- **Git**: Latest

### Development Tools (Recommended)
- **VS Code** with extensions:
  - PHP Intelephense
  - Laravel Blade Snippets
  - ESLint
  - Prettier
  - TypeScript and JavaScript Language Features
- **Postman** or **Insomnia** for API testing
- **TablePlus** or **pgAdmin** for database management

---

## 2. Backend Setup (Laravel)

### Step 1: Create Laravel Project

```bash
# Navigate to your projects directory
cd /path/to/projects

# Create new Laravel project
composer create-project laravel/laravel financechat-backend

# Navigate into project
cd financechat-backend

# Install required packages
composer require laravel/sanctum
composer require thiagoalessio/tesseract_ocr
composer require imagick
composer require pestphp/pest --dev --with-all-dependencies

# Initialize Pest
php artisan pest:install
```

### Step 2: Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

Edit `.env`:

```env
APP_NAME=FinanceChat
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=financechat
DB_USERNAME=your_db_username
DB_PASSWORD=your_db_password

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Queue
QUEUE_CONNECTION=redis

# Claude API
CLAUDE_API_KEY=your_claude_api_key_here
CLAUDE_MODEL=claude-3-5-sonnet-20241022

# Filesystem
FILESYSTEM_DISK=local

# CORS
SANCTUM_STATEFUL_DOMAINS=localhost:3000
SESSION_DOMAIN=localhost
```

### Step 3: Install Sanctum

```bash
# Publish Sanctum config
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Run migrations
php artisan migrate
```

Edit `config/sanctum.php`:

```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1')),
```

### Step 4: Create Directory Structure

```bash
# Create directories
mkdir -p app/DTOs
mkdir -p app/Services
mkdir -p app/Repositories
mkdir -p app/Jobs

# Create storage directories
mkdir -p storage/app/private/receipts
mkdir -p storage/app/private/bank-statements
```

### Step 5: Copy Implementation Files

Copy all the code from these documentation files into your Laravel project:

1. **Database Migrations**: From `DATABASE_MIGRATIONS.md`
   - Place in `database/migrations/`

2. **Models**: From `LARAVEL_BACKEND_STRUCTURE.md`
   - Place in `app/Models/`

3. **Controllers**: From `LARAVEL_BACKEND_STRUCTURE.md`
   - Place in `app/Http/Controllers/`

4. **Services**: From both structure files
   - Place in `app/Services/`

5. **Repositories**: From structure files
   - Place in `app/Repositories/`

6. **Jobs**: From `LARAVEL_OCR_AI_IMPLEMENTATION.md`
   - Place in `app/Jobs/`

7. **Routes**: From `LARAVEL_BACKEND_STRUCTURE.md`
   - Update `routes/api.php`

### Step 6: Run Migrations and Seeders

```bash
# Run all migrations
php artisan migrate

# Seed predefined categories
php artisan db:seed --class=CategorySeeder
```

### Step 7: Configure CORS

Edit `config/cors.php`:

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['http://localhost:3000'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### Step 8: Start Development Server

```bash
# Start Laravel development server
php artisan serve

# In another terminal, start queue worker
php artisan queue:work redis --tries=3 --timeout=600
```

The API should now be running at `http://localhost:8000`

---

## 3. Frontend Setup (Next.js)

### Step 1: Create Next.js Project

```bash
# Navigate to projects directory
cd /path/to/projects

# Create Next.js app with TypeScript
npx create-next-app@latest financechat-frontend --typescript --tailwind --app --use-npm

# Navigate into project
cd financechat-frontend
```

### Step 2: Install Dependencies

```bash
# Install all required packages
npm install @tanstack/react-query @tanstack/react-query-devtools
npm install zustand axios
npm install recharts date-fns
npm install zod react-hook-form @hookform/resolvers
npm install lucide-react
npm install class-variance-authority clsx tailwind-merge
npm install tailwindcss-animate
npm install sonner
```

### Step 3: Install shadcn/ui

```bash
# Initialize shadcn/ui
npx shadcn-ui@latest init

# Install required components
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
```

### Step 4: Configure Environment

Create `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_APP_NAME=FinanceChat
```

### Step 5: Copy Implementation Files

Copy all code from these files into your Next.js project:

1. **Configuration Files**:
   - `tsconfig.json`
   - `tailwind.config.ts`
   - `next.config.js`

2. **Global Styles**: From `NEXTJS_FRONTEND_STRUCTURE.md`
   - `src/app/globals.css`

3. **API Client**: From `NEXTJS_FRONTEND_STRUCTURE.md`
   - Place in `src/lib/api/`

4. **Type Definitions**: From `NEXTJS_FRONTEND_STRUCTURE.md`
   - Place in `src/lib/types/`

5. **Hooks**: From `NEXTJS_FRONTEND_STRUCTURE.md`
   - Place in `src/lib/hooks/`

6. **Stores**: From `NEXTJS_FRONTEND_STRUCTURE.md`
   - Place in `src/lib/stores/`

7. **Components**: From `NEXTJS_COMPONENTS.md`
   - Place in `src/components/`

8. **Pages**: From `NEXTJS_COMPONENTS.md`
   - Place in `src/app/`

### Step 6: Start Development Server

```bash
# Start Next.js development server
npm run dev
```

The frontend should now be running at `http://localhost:3000`

---

## 4. Database Setup

### Step 1: Install PostgreSQL

**macOS (Homebrew)**:
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install postgresql-15 postgresql-contrib
sudo systemctl start postgresql
```

**Windows**:
Download installer from [postgresql.org](https://www.postgresql.org/download/windows/)

### Step 2: Create Database and User

```bash
# Connect to PostgreSQL
psql postgres

# In psql:
CREATE DATABASE financechat;
CREATE USER financechat_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE financechat TO financechat_user;
\q
```

### Step 3: Test Connection

```bash
# From Laravel project directory
php artisan migrate:status
```

---

## 5. OCR Setup

### Step 1: Install Tesseract OCR

**macOS (Homebrew)**:
```bash
brew install tesseract
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install tesseract-ocr
sudo apt install libtesseract-dev
```

**Windows**:
Download from [github.com/UB-Mannheim/tesseract](https://github.com/UB-Mannheim/tesseract/wiki)

### Step 2: Install Imagick (for PDF processing)

**macOS (Homebrew)**:
```bash
brew install imagemagick
pecl install imagick
```

**Ubuntu/Debian**:
```bash
sudo apt install imagemagick
sudo apt install php-imagick
```

### Step 3: Verify Installation

```bash
# Check Tesseract
tesseract --version

# Check Imagick
php -m | grep imagick
```

### Step 4: Configure PHP

Edit `php.ini`:
```ini
extension=imagick.so
```

Restart PHP-FPM:
```bash
sudo service php8.3-fpm restart
```

---

## 6. Claude API Integration

### Step 1: Get API Key

1. Go to [console.anthropic.com](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys
4. Create a new API key
5. Copy the key

### Step 2: Configure in Laravel

Add to `.env`:
```env
CLAUDE_API_KEY=sk-ant-api03-your-key-here
CLAUDE_MODEL=claude-3-5-sonnet-20241022
```

### Step 3: Configure in Services

Edit `config/services.php`:
```php
'claude' => [
    'api_key' => env('CLAUDE_API_KEY'),
    'model' => env('CLAUDE_MODEL', 'claude-3-5-sonnet-20241022'),
],
```

### Step 4: Test Integration

Create a test route in `routes/api.php`:
```php
Route::get('/test-claude', function () {
    $claudeService = new \App\Services\ClaudeService();
    $response = $claudeService->sendMessage(
        messages: [['role' => 'user', 'content' => 'Say hello!']],
        systemPrompt: 'You are a helpful assistant.'
    );
    return $response;
});
```

Test:
```bash
curl http://localhost:8000/api/test-claude
```

---

## 7. Testing

### Backend Testing (Pest)

Create test file `tests/Feature/TransactionTest.php`:

```php
<?php

use App\Models\User;

test('user can create transaction', function () {
    $user = User::factory()->create();
    $category = \App\Models\Category::factory()->create(['user_id' => $user->id]);

    $response = $this->actingAs($user)
        ->postJson('/api/transactions', [
            'amount' => 100.50,
            'type' => 'expense',
            'description' => 'Test transaction',
            'category_id' => $category->id,
        ]);

    $response->assertStatus(201);
    $response->assertJsonStructure([
        'data' => [
            'id',
            'amount',
            'type',
            'description',
        ],
    ]);
});
```

Run tests:
```bash
php artisan test
```

### Frontend Testing

Run type checking:
```bash
npm run type-check
```

Run linter:
```bash
npm run lint
```

---

## 8. Deployment

### Backend Deployment (VPS/Cloud)

#### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.3
sudo add-apt-repository ppa:ondrej/php
sudo apt install php8.3 php8.3-fpm php8.3-pgsql php8.3-mbstring php8.3-xml php8.3-bcmath php8.3-curl php8.3-redis

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Install Redis
sudo apt install redis-server

# Install Nginx
sudo apt install nginx

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Tesseract & Imagick
sudo apt install tesseract-ocr imagemagick php8.3-imagick
```

#### 2. Clone and Setup Project

```bash
# Clone repository
cd /var/www
sudo git clone https://github.com/yourorg/financechat-backend.git
sudo chown -R www-data:www-data financechat-backend

# Install dependencies
cd financechat-backend
composer install --optimize-autoloader --no-dev

# Setup environment
cp .env.example .env
php artisan key:generate

# Run migrations
php artisan migrate --force

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### 3. Configure Nginx

Create `/etc/nginx/sites-available/financechat-api`:

```nginx
server {
    listen 80;
    server_name api.financechat.com;
    root /var/www/financechat-backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    client_max_body_size 10M;
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/financechat-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 4. Setup Queue Worker (Supervisor)

Create `/etc/supervisor/conf.d/financechat-worker.conf`:

```ini
[program:financechat-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/financechat-backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/financechat-backend/storage/logs/worker.log
stopwaitsecs=3600
```

Start supervisor:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start financechat-worker:*
```

#### 5. Setup SSL (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.financechat.com
```

### Frontend Deployment (Vercel - Recommended)

#### 1. Connect GitHub Repository

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Import your repository
4. Configure environment variables:
   - `NEXT_PUBLIC_API_URL`: https://api.financechat.com/api

#### 2. Deploy

Vercel will automatically build and deploy.

### Alternative: Frontend on VPS

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Clone repository
cd /var/www
sudo git clone https://github.com/yourorg/financechat-frontend.git

# Install and build
cd financechat-frontend
npm ci
npm run build

# Install PM2
sudo npm install -g pm2

# Start application
pm2 start npm --name "financechat-frontend" -- start
pm2 save
pm2 startup
```

Configure Nginx for frontend (similar to backend).

---

## Quick Start Commands

### Backend
```bash
php artisan serve                    # Start dev server
php artisan queue:work               # Start queue worker
php artisan migrate:fresh --seed     # Reset database
php artisan test                     # Run tests
```

### Frontend
```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run linter
npm run type-check   # Check TypeScript
```

---

## Troubleshooting

### Common Issues

**1. CORS errors**
- Check `SANCTUM_STATEFUL_DOMAINS` in `.env`
- Verify `config/cors.php` settings

**2. Queue jobs not processing**
- Check Redis is running: `redis-cli ping`
- Check queue worker is running
- Check logs: `storage/logs/laravel.log`

**3. OCR failures**
- Verify Tesseract installation: `tesseract --version`
- Check file permissions on `storage/app/private/`
- Review queue job logs

**4. API connection errors**
- Verify `NEXT_PUBLIC_API_URL` in `.env.local`
- Check CORS configuration
- Verify API is running

---

## Next Steps

1. **Add Tests**: Write comprehensive tests for all features
2. **Performance Optimization**: Add caching, optimize queries
3. **Monitoring**: Setup error tracking (Sentry), uptime monitoring
4. **Backups**: Automated database backups
5. **CI/CD**: Setup GitHub Actions for automated testing and deployment

---

**Documentation Version**: 1.0
**Last Updated**: 2025-01-24
