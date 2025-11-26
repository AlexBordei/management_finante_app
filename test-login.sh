#!/bin/bash

echo "================================"
echo "Testing FinanceChat Login System"
echo "================================"
echo ""

# Test 1: Backend is running
echo "1. Testing if backend is running..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/categories 2>/dev/null)
if [ "$BACKEND_STATUS" == "401" ]; then
    echo "✅ Backend is running (returns 401 for unauthenticated request)"
else
    echo "❌ Backend might not be running. Status: $BACKEND_STATUS"
fi
echo ""

# Test 2: Login with test user
echo "2. Testing login with existing user..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login successful! Token: ${TOKEN:0:20}..."
else
    echo "❌ Login failed. Response:"
    echo "$LOGIN_RESPONSE" | jq '.' 2>/dev/null || echo "$LOGIN_RESPONSE"
fi
echo ""

# Test 3: Try alternative credentials
echo "3. Testing login with debug user..."
ALT_LOGIN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "debug@test.com",
    "password": "testpassword123"
  }')

ALT_TOKEN=$(echo $ALT_LOGIN | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$ALT_TOKEN" ]; then
    echo "✅ Alternative login successful!"
else
    echo "❌ Alternative login failed"
fi
echo ""

# Test 4: Check CORS
echo "4. Testing CORS headers..."
CORS_RESPONSE=$(curl -s -I http://localhost:8000/api/categories \
  -H "Origin: http://localhost:3000" 2>/dev/null | grep -i "access-control")

if [ ! -z "$CORS_RESPONSE" ]; then
    echo "✅ CORS headers present:"
    echo "$CORS_RESPONSE"
else
    echo "⚠️  No CORS headers found"
fi
echo ""

# Test 5: Frontend is running
echo "5. Testing if frontend is running..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
if [ "$FRONTEND_STATUS" == "200" ]; then
    echo "✅ Frontend is running"
else
    echo "❌ Frontend might not be running. Status: $FRONTEND_STATUS"
fi
echo ""

echo "================================"
echo "Credentials to try:"
echo "Email: test@example.com"
echo "Password: password123"
echo ""
echo "OR"
echo ""
echo "Email: debug@test.com"
echo "Password: testpassword123"
echo "================================"
