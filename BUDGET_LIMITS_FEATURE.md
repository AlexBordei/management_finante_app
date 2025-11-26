# Feature: Limite Bugetare Lunare

## Descriere
Sistem de limite bugetare lunare cu notificări/atenționări în dashboard. **Nu blochează plățile**, doar oferă avertizări când cheltuielile se apropie de limită.

## Backend API

### Endpoints Disponibile

#### 1. CRUD pentru Budget Limits
- `GET /api/budget-limits` - Listă toate limitele
- `POST /api/budget-limits` - Creează limită nouă
  ```json
  {
    "category_id": 1,
    "amount": 1500.00,
    "alert_threshold": 80
  }
  ```
- `GET /api/budget-limits/{id}` - Detalii limită
- `PUT /api/budget-limits/{id}` - Actualizează limită
- `DELETE /api/budget-limits/{id}` - Șterge limită

#### 2. Endpoints Speciale
- `GET /api/budget-limits/stats/status` - Status toate limitele + alerte active
- `GET /api/budget-limits/available-categories` - Categorii disponibile pentru setare limite
- `GET /api/analytics/overview` - Include și `budget_alerts` în răspuns

### Răspuns API Exemplu

**GET /api/budget-limits/available-categories**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Food & Dining",
      "icon": "utensils",
      "color": "#FF6B6B",
      "has_active_limit": true
    },
    {
      "id": 7,
      "name": "Shopping",
      "icon": "shopping-bag",
      "color": "#5F27CD",
      "has_active_limit": false
    }
  ]
}
```

**GET /api/budget-limits/stats/status**
```json
{
  "success": true,
  "data": {
    "alerts": [
      {
        "id": 3,
        "category_id": 7,
        "category_name": "Shopping",
        "category_icon": "shopping-bag",
        "limit_amount": 500.00,
        "current_spending": 1850.00,
        "remaining_amount": 0,
        "usage_percentage": 370.00,
        "alert_threshold": 75,
        "is_exceeded": true,
        "severity": "critical",
        "message": "Ai depășit limita pentru Shopping! Ai cheltuit 1,850.00 RON din 500.00 RON (cu 1,350.00 RON peste limită)."
      }
    ],
    "all_limits": [
      {
        "id": 1,
        "category_id": 1,
        "category_name": "Food & Dining",
        "category_icon": "utensils",
        "limit_amount": 1500.00,
        "current_spending": 1495.00,
        "remaining_amount": 5.00,
        "usage_percentage": 99.67,
        "is_exceeded": false,
        "has_alert": true
      }
    ]
  }
}
```

### Niveluri de Severitate Alerte
- **critical** (roșu) - Limită depășită (≥100%)
- **high** (portocaliu) - Foarte aproape (≥90%)
- **medium** (galben) - Aproape de limită (≥75%)
- **low** (albastru) - Peste prag dar sub 75%

## Frontend

### Pagină Nouă
- **URL**: `/budget-limits`
- **Locație**: `src/app/budget-limits/page.tsx`
- **Navigare**: Adăugat în meniul principal cu iconița Target 🎯

### Funcționalități UI
1. **Vizualizare limite** - Cards cu progres vizual
2. **Adăugare limită** - Dialog cu form pentru:
   - Selectare categorie (doar cele fără limite active)
   - Setare sumă limită
   - Setare prag alertă (%)
3. **Ștergere limită** - Buton de ștergere cu confirmare
4. **Statusuri vizuale**:
   - Badge "OK" (verde) - Sub pragul de alertă
   - Badge "Atenție" (portocaliu) - La/peste prag dar sub limită
   - Badge "Depășită" (roșu) - Peste limită
5. **Progress bar** cu culori dinamice

### Componente Create
- `src/app/budget-limits/page.tsx` - Pagina principală
- Modificat `src/components/DashboardLayout.tsx` - Adăugat link în navigare

## Baza de Date

### Tabel: `budget_limits`
```sql
CREATE TABLE budget_limits (
  id BIGINT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  category_id BIGINT NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  alert_threshold INTEGER DEFAULT 80,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
```

### Model: `BudgetLimit`
Locație: `app/Models/BudgetLimit.php`

Metode utile:
- `isExceeded(float $currentSpending): bool`
- `shouldAlert(float $currentSpending): bool`
- `getUsagePercentage(float $currentSpending): float`

### Service: `BudgetAlertService`
Locație: `app/Services/BudgetAlertService.php`

Metode:
- `generateAlerts(int $userId): array` - Generează doar alertele active
- `getAllLimitsStatus(int $userId): array` - Toate limitele cu status

## Date de Test

Userul de test (`test@example.com`) are 5 limite bugetare setate:
1. **Food & Dining**: 1,500 RON (prag 80%)
2. **Transportation**: 600 RON (prag 85%)
3. **Shopping**: 500 RON (prag 75%) - **VA FI DEPĂȘITĂ în noiembrie cu Black Friday**
4. **Entertainment**: 300 RON (prag 80%)
5. **Utilities**: 800 RON (prag 90%)

## Cum să Testezi

### 1. Backend Testing
```bash
# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Obține categoriile disponibile
curl http://localhost:8000/api/budget-limits/available-categories \
  -H "Authorization: Bearer YOUR_TOKEN"

# Obține status-ul limitelor
curl http://localhost:8000/api/budget-limits/stats/status \
  -H "Authorization: Bearer YOUR_TOKEN"

# Creează o limită nouă
curl -X POST http://localhost:8000/api/budget-limits \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"category_id": 8, "amount": 400, "alert_threshold": 80}'
```

### 2. Frontend Testing
1. Pornește frontend-ul: `cd financechat-frontend && npm run dev`
2. Login cu `test@example.com` / `password123`
3. Click pe "Budget Limits" în meniul de navigare
4. Ar trebui să vezi 5 limite deja setate cu progress bars
5. Încearcă să adaugi o limită nouă pentru o categorie disponibilă
6. Testează ștergerea unei limite

### 3. Verificare Alerte în Dashboard
1. Mergi la `/dashboard`
2. Backend-ul ar trebui să includă `budget_alerts` în răspunsul de la `/api/analytics/overview`
3. Shopping ar trebui să aibă alertă de tip "critical" (depășită)

## Caracteristici Importante

✅ **Limitele sunt lunare** - Se calculează doar cheltuielile din luna curentă
✅ **Nu blochează plățile** - Doar notificări/atenționări
✅ **Prag configu rabil** - Poți seta când vrei să primești alerta (ex: la 80%, 90%, etc.)
✅ **O limită per categorie** - Nu poți avea multiple limite active pentru aceeași categorie
✅ **Poate fi dezactivată** - Fără să o ștergi (prin `is_active`)
✅ **Mesaje în română** - Toate mesajele sunt traduse

## Migrații

Pentru a rula migrația:
```bash
cd financechat-backend
php artisan migrate
php artisan db:seed --class=TestDataSeeder
```

## Fișiere Create/Modificate

### Backend
- ✅ `database/migrations/2024_01_15_000006_create_budget_limits_table.php`
- ✅ `app/Models/BudgetLimit.php`
- ✅ `app/Http/Controllers/BudgetLimitController.php`
- ✅ `app/Services/BudgetAlertService.php`
- ✅ `routes/api.php` (adăugat rute)
- ✅ `app/Http/Controllers/AnalyticsController.php` (adăugat alerte în overview)
- ✅ `database/seeders/TestDataSeeder.php` (adăugat date de test)

### Frontend
- ✅ `src/app/budget-limits/page.tsx`
- ✅ `src/components/DashboardLayout.tsx` (adăugat link în navigare)

## Viitor / Îmbunătățiri Posibile

- [ ] Notificări push când atingi limita
- [ ] Istoricul limitelor (arhivare)
- [ ] Limite pe multiple perioade (săptămânale, anuale)
- [ ] Export raport limite
- [ ] Grafice trend cheltuieli vs limite
- [ ] Sugestii automate de limite bazate pe istoric
- [ ] Editare limită existentă (momentan doar ștergere + recreare)
