# Funcționalitatea de Economii (Savings Goals)

## Prezentare Generală

Funcționalitatea de economii permite utilizatorilor să își seteze obiective financiare și să urmărească progresul acestora. Când un utilizator adaugă bani într-un obiectiv de economii, sistemul creează automat o tranzacție de tip "expense" și afișează mesaje motivaționale.

## Structura Bazei de Date

### Tabelul `savings_goals`
```sql
- id: bigint
- user_id: bigint (FK -> users)
- name: string (ex: "Vacanță în Grecia", "Laptop nou")
- description: text (optional)
- target_amount: decimal(15,2) - suma țintă
- current_amount: decimal(15,2) - suma economisită curent
- target_date: date (optional) - data țintă
- color: string(7) - culoare hex pentru UI (default: #4CAF50)
- icon: string - emoji sau nume icon
- is_completed: boolean - dacă obiectivul a fost atins
- completed_at: timestamp - când a fost atins obiectivul
- timestamps
```

### Tabelul `savings_contributions`
```sql
- id: bigint
- savings_goal_id: bigint (FK -> savings_goals)
- transaction_id: bigint (FK -> transactions)
- amount: decimal(15,2)
- note: text (optional)
- timestamps
```

## API Endpoints

### 1. Listează toate obiectivele de economii
```
GET /api/savings-goals
Query params:
  - status: 'active' | 'completed' (optional)
```

**Exemplu răspuns:**
```json
[
  {
    "id": 1,
    "name": "Vacanță în Grecia",
    "description": "Economii pentru vacanța de vară",
    "target_amount": "5000.00",
    "current_amount": "2500.00",
    "target_date": "2026-07-01",
    "color": "#FF5722",
    "icon": "🏖️",
    "is_completed": false,
    "progress_percentage": 50,
    "remaining_amount": 2500,
    "contributions": [...]
  }
]
```

### 2. Creează un obiectiv nou
```
POST /api/savings-goals
Body: {
  "name": "Laptop nou",
  "description": "Economii pentru laptop de gaming",
  "target_amount": 3000,
  "target_date": "2026-12-31" (optional),
  "color": "#2196F3" (optional),
  "icon": "💻" (optional)
}
```

### 3. Detalii obiectiv
```
GET /api/savings-goals/{id}
```

### 4. Actualizează obiectiv
```
PUT /api/savings-goals/{id}
Body: {
  "name": "Laptop nou",
  "target_amount": 3500
}
```

### 5. Șterge obiectiv
```
DELETE /api/savings-goals/{id}
```

### 6. Adaugă contribuție (PRINCIPAL)
```
POST /api/savings-goals/{id}/contribute
Body: {
  "amount": 500,
  "description": "Economie lunară noiembrie" (optional),
  "date": "2025-11-26" (optional),
  "category_id": 5 (optional)
}
```

**Ce se întâmplă:**
1. Creează o tranzacție de tip "expense" cu `source="savings"`
2. Adaugă contribuția la obiectivul de economii
3. Actualizează `current_amount` din obiectiv
4. Verifică dacă obiectivul a fost atins (`current_amount >= target_amount`)
5. Returnează mesaj motivațional

**Exemplu răspuns când economisești:**
```json
{
  "message": "🚀 Fantastic! Ai economisit 500 RON! 'Laptop nou' este acum 26.67% completat!",
  "savings_goal": {...},
  "transaction": {...},
  "contribution": {...}
}
```

**Exemplu răspuns când atingi obiectivul:**
```json
{
  "message": "🏆 Excelent! Obiectivul 'Laptop nou' a fost atins! Continuă tot așa!",
  "savings_goal": {
    "is_completed": true,
    "completed_at": "2025-11-26T17:33:30.000000Z",
    "progress_percentage": 100,
    ...
  },
  "transaction": {...},
  "contribution": {...}
}
```

### 7. Statistici generale
```
GET /api/savings/statistics
```

**Răspuns:**
```json
{
  "total_savings_goals": 2,
  "active_goals": 1,
  "completed_goals": 1,
  "total_saved": "5800.00",
  "total_target": "3000.00"
}
```

## Filtrarea Tranzacțiilor

### Excluderea tranzacțiilor de savings din lista normală
```
GET /api/transactions
```
Implicit, acest endpoint **exclude** tranzacțiile cu `source="savings"`.

### Vizualizarea doar a tranzacțiilor de savings
```
GET /api/transactions?source=savings
```

### Vizualizarea tuturor tranzacțiilor (inclusiv savings)
```
GET /api/transactions?source=all
```

## Mesaje Motivaționale

### Când economisești (obiectiv neatins):
- "💰 Super! Ai adăugat {amount} RON la '{name}'! Mai ai nevoie de {remaining} RON ({progress}% completat)"
- "🎯 Bravo! Încă {amount} RON economisiți pentru '{name}'! Ești la {progress}% din țintă!"
- "⭐ Grozav! {amount} RON mai aproape de '{name}'! Mai ai {remaining} RON până la obiectiv!"
- "🚀 Fantastic! Ai economisit {amount} RON! '{name}' este acum {progress}% completat!"
- "💪 Foarte bine! {amount} RON în plus pentru '{name}'! Continuă așa!"

### Când atingi obiectivul:
- "🎉 Felicitări! Ai atins obiectivul tău de economii pentru '{name}'! Incredibil!"
- "🌟 Bravo! Ai reușit să economisești {target_amount} RON pentru '{name}'! Ești fantastic!"
- "🏆 Excelent! Obiectivul '{name}' a fost atins! Continuă tot așa!"
- "💪 Wow! Ai demonstrat disciplină financiară exemplară! '{name}' - Realizat!"
- "✨ Felicitări pentru atingerea obiectivului '{name}'! Munca ta a dat roade!"

## Exemple de Utilizare

### 1. Creează obiectiv de vacanță
```bash
curl -X POST http://localhost:8000/api/savings-goals \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vacanță în Grecia",
    "description": "Economii pentru vacanța de vară",
    "target_amount": 5000,
    "target_date": "2026-07-01",
    "color": "#FF5722",
    "icon": "🏖️"
  }'
```

### 2. Adaugă contribuție lunară
```bash
curl -X POST http://localhost:8000/api/savings-goals/1/contribute \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 500,
    "description": "Economie lunară noiembrie"
  }'
```

### 3. Vezi progresul
```bash
curl http://localhost:8000/api/savings-goals \
  -H "Authorization: Bearer {token}"
```

### 4. Vezi statistici generale
```bash
curl http://localhost:8000/api/savings/statistics \
  -H "Authorization: Bearer {token}"
```

## Integrare Frontend

### Componentele necesare:
1. **Savings Dashboard** - listă cu toate obiectivele
2. **Progress Bars** - vizualizare progres pentru fiecare obiectiv
3. **Add Contribution Modal** - formular pentru adăugare contribuție
4. **Success Toast** - afișează mesajele motivaționale
5. **Statistics Widget** - widget cu statistici generale

### Date calculate automat:
- `progress_percentage` - procentul atins (0-100)
- `remaining_amount` - suma rămasă până la obiectiv
- `is_completed` - status obiectiv atins/neatins

## Beneficii

✅ **Tracking automat** - toate contribuțiile sunt înregistrate ca tranzacții
✅ **Mesaje motivaționale** - încurajează utilizatorii să economisească
✅ **Vizualizare progres** - bară de progres pentru fiecare obiectiv
✅ **Separare clară** - tranzacțiile de savings sunt separate de cele normale
✅ **Flexibilitate** - poți avea multiple obiective simultan
✅ **Statistici** - overview complet asupra economiilor tale

## Modele Laravel

### SavingsGoal.php
- Relații: `user()`, `contributions()`
- Metode: `addContribution($amount, $transactionId, $note)`
- Atribute calculate: `progress_percentage`, `remaining_amount`

### SavingsContribution.php
- Relații: `savingsGoal()`, `transaction()`

### Transaction.php
- Relație nouă: `savingsContribution()`
- Source nou: `'savings'`

### User.php
- Relație nouă: `savingsGoals()`
