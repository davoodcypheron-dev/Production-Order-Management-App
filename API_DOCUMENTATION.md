# Nexus Prod - API Documentation

This document outlines the REST API endpoints provided by the **Nexus Prod** server, including request methods, URL paths, parameters, description, and sample JSON payloads.

All API requests should be sent to the base URL: `http://localhost:5000/api`

---

## Authentication Endpoints

### 1. User Login
Validates credentials against the `user_master` table. On success, returns the username and user ID.

- **Method:** `POST`
- **Path:** `/login`
- **Request Headers:** `Content-Type: application/json`

#### Sample Request
```json
{
  "username": "admin",
  "password": "12345"
}
```

#### Sample Response (Success)
```json
{
  "success": true,
  "user": "admin",
  "userId": 1
}
```

#### Sample Response (Failure)
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

## Invoice Generation Endpoints

### 2. Check Pending Orders
Checks if there are any orders in the `order_distribution` table that have not yet had invoices generated (`inv_gen = 0`).

- **Method:** `GET`
- **Path:** `/orders/check-pending`

#### Sample Response (Pending Orders Exist)
```json
{
  "success": true,
  "pendingExist": true
}
```

#### Sample Response (No Pending Orders)
```json
{
  "success": true,
  "pendingExist": false
}
```

---

### 3. Generate Invoices
Finds all groups of `(branch_id, trip_id)` with pending orders (`inv_gen = 0`), generates corresponding `sales_master` (invoices) and `sales_details` records for each group, and updates `inv_gen = 1` in `order_distribution`.

- **Method:** `POST`
- **Path:** `/orders/generate-invoices`
- **Request Headers:** `Content-Type: application/json`

#### Sample Request
```json
{
  "userId": 1
}
```

#### Sample Response (Success)
```json
{
  "success": true,
  "message": "21 invoices generated successfully."
}
```

---

## Lookups and Lists

### 4. Get Sections
Retrieves the list of active section names from the `sections` table.

- **Method:** `GET`
- **Path:** `/sections`

#### Sample Response
```json
{
  "sections": [
    "Fresh Bakery",
    "Beverages",
    "Dairy Products",
    "Snacks"
  ]
}
```

---

### 5. Get Trips for Section
Retrieves all unique trip names that currently have invoices (`sales_master`) containing items belonging to the specified section.

- **Method:** `GET`
- **Path:** `/trips/:section`
- **URL Parameters:** `section` (URL-encoded section name, e.g., `Fresh%20Bakery`)

#### Sample Response
```json
{
  "trips": [
    "06:00 AM Trip",
    "09:00 AM Trip",
    "12:00 PM Trip",
    "03:00 PM Trip",
    "06:00 PM Trip"
  ]
}
```

---

### 6. Get Orders list
Fetches items and their branch distribution details for the selected section and delivery trip directly from the generated invoices (`sales_master` and `sales_details`).

- **Method:** `GET`
- **Path:** `/orders/:section/:trip`
- **URL Parameters:** 
  - `section` (URL-encoded section name, e.g., `Fresh%20Bakery`)
  - `trip` (URL-encoded trip name, e.g., `06:00%20AM%20Trip`)

#### Sample Response
```json
{
  "orders": [
    {
      "id": 1,
      "name": "Artisan Sourdough",
      "unit": "Loaf",
      "isCompleted": false,
      "distribution": [
        {
          "branch": "Main Warehouse",
          "trip": "06:00 AM Trip",
          "qty": 45
        },
        {
          "branch": "North Side Hub",
          "trip": "06:00 AM Trip",
          "qty": 30
        }
      ]
    },
    {
      "id": 2,
      "name": "Butter Croissant",
      "unit": "Pack",
      "isCompleted": true,
      "distribution": [
        {
          "branch": "Main Warehouse",
          "trip": "06:00 AM Trip",
          "qty": 45
        }
      ]
    }
  ]
}
```

---

## Invoice Updates and Rollovers

### 7. Update Invoice Quantities
Updates the item quantities and totals in the invoice details (`sales_details`) for the given item, trip, and branch list, and marks them completed (`is_completed = 1`). Recalculates the main invoice value (`sales_master.total_value`).

- **Method:** `POST`
- **Path:** `/orders/update`
- **Request Headers:** `Content-Type: application/json`

#### Sample Request
```json
{
  "itemId": 1,
  "trip": "06:00 AM Trip",
  "newDistribution": [
    {
      "branch": "Main Warehouse",
      "qty": 50
    },
    {
      "branch": "North Side Hub",
      "qty": 30
    }
  ]
}
```

#### Sample Response
```json
{
  "success": true,
  "message": "Invoice updated in MySQL for item 1"
}
```

---

### 8. Exclude and Rollover Item
Excludes an item from the current trip's invoice (deletes its `sales_details` record) for a single branch or for all branches, and automatically rolls the quantities over to the next chronologically scheduled trip's invoice (creating one if it doesn't exist).

- **Method:** `POST`
- **Path:** `/orders/exclude`
- **Request Headers:** `Content-Type: application/json`

#### Sample Request (Exclude Single Branch with Rollover)
```json
{
  "section": "Fresh Bakery",
  "itemId": 1,
  "currentTrip": "06:00 AM Trip",
  "branch": "North Side Hub"
}
```

#### Sample Request (Exclude All Branches on Trip)
```json
{
  "section": "Fresh Bakery",
  "itemId": 1,
  "currentTrip": "06:00 AM Trip",
  "branch": null
}
```

#### Sample Response (Rollover Succeeded)
```json
{
  "success": true,
  "message": "Excluded from 06:00 AM Trip. Rolled over to 09:00 AM Trip."
}
```

#### Sample Response (Final Trip Reached - Removed)
```json
{
  "success": true,
  "message": "Excluded from 06:00 AM Trip. Item removed completely as no next trip exists."
}
```

---

## Technical Configuration Endpoints

### 9. Save Database Configuration
Overwrites connection credentials in `server/db_config.json` and updates the active mode to use local MySQL.

- **Method:** `POST`
- **Path:** `/config`
- **Request Headers:** `Content-Type: application/json`

#### Sample Request
```json
{
  "host": "localhost",
  "port": 3306,
  "user": "root",
  "password": "admin@5555",
  "database": "prod_app",
  "use_mock_db": false
}
```

#### Sample Response
```json
{
  "success": true,
  "message": "Configuration saved successfully. Please restart server if needed."
}
```

---

### 10. Test Database Connection
Pings a target database server to test credentials without saving them.

- **Method:** `POST`
- **Path:** `/test-db`
- **Request Headers:** `Content-Type: application/json`

#### Sample Request
```json
{
  "host": "localhost",
  "port": 3306,
  "user": "root",
  "password": "admin@5555",
  "database": "prod_app"
}
```

#### Sample Response (Success)
```json
{
  "success": true,
  "message": "Database connection successful!"
}
```

#### Sample Response (Failure)
```json
{
  "success": false,
  "message": "connect ECONNREFUSED 127.0.0.1:3306"
}
```
