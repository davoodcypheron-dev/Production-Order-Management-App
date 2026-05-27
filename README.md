# Nexus Prod - Production Order Management App

## Overview
**Nexus Prod** is a full-stack Production Order Management Portal tailored for processing and tracking daily production distributions across multiple shifts (trips) and facility sections (e.g., Fresh Bakery, Beverages). It provides an intuitive interface to verify pending load sheets, confirm load completion accurately, and rapidly cycle through required branches and items.

## Technology Stack
- **Frontend/Client**: React 19, Vite, Tailwind CSS (v4), React Router DOM (v7), and Lucide-React for modern icons.
- **Backend/Server**: Node.js, Express.js, MySQL Promise wrapper.
- **Database**: MySQL Server (supported with a robust Mock DB fallback for rapid offline testing).
- **Tooling**: Concurrently handles both client and server startup via a custom Node script.

## Project Structure
```text
production-order-management-app/
│
├── client/                     # React + Vite Frontend
│   ├── src/                    
│   │   ├── components/         # Reusable UI components (Loader, Modals)
│   │   ├── pages/              # App routes (Login, Dashboard)
│   │   ├── services/           # API fetch wrappers (api.js)
│   │   └── index.css           # Tailwind injection point
│   └── package.json            
│
├── server/                     # Express Backend
│   ├── db/                     # DB Logic (mysql_db.js, mock_db.js, index.js router)
│   ├── db_config.json          # Active database connection config & mock toggle
│   ├── server.js               # Express application and API routers
│   └── package.json
│
├── scripts/                    
│   └── start.js                # Shell script to boot client and server in parallel
│
└── package.json                # Root package manager handling global scripts
```

## Setup & Installation

**Prerequisites:** Node.js installed on your machine. MySQL Server (optional if relying strictly on Mock Mode).

1. **Install Dependencies:**
   From the root folder, run the global installation command to install both frontend and backend dependencies at once:
   ```bash
   npm run install-all
   ```

2. **Start the Application:**
   Run the following command in the root folder to boot both the server (Port 5000) and the client (Vite network port):
   ```bash
   npm start
   ```

## Complete Application Workflow

### 1. Database Configuration & Login
- **Configuration Panel:** On the Login Page, the user has the option to click **Database Configuration**. This opens a modal to input MySQL connection details (Host, Port, DB Name, User, Password).
- **Test & Save:** Users can test the connection in real-time. Once successful, saving writes the credentials and the `use_mock_db=false` flag directly to the server's `db_config.json`.
- **Login Authentication:** After configuration, the user logs in. Upon successful verification, the app sets a local authentication token and redirects to the **Dashboard**.

### 2. Initial Dashboard Load (Invoice Generation)
- **Pending Orders Check:** When the dashboard loads, the system checks for any new, non-billed orders for the current day.
- **Generation Prompt:** If unbilled orders exist, a prompt appears asking to **Generate Invoices**. 
- **Generate vs. Later:** 
  - Clicking **Generate** runs a backend process to compile and spawn the raw invoices for the day.
  - Clicking **Later** simply closes the prompt and loads the standard Dashboard interface.

### 3. Load Processing & Routing
- **Section Selection:** The left card prompts the user to select the production section (e.g., "Fresh Bakery"). The application then fetches available shipping trips from the generated invoices based on this section.
- **Trip Selection:** The right card unlocks, allowing the user to select a trip (e.g., "06:00 AM Trip"). *Note: If no invoices have been generated for a section, the trip selector will remain empty/locked.*
- **Order Population:** Once both Section and Trip are selected, the system pulls the specific items needed for that trip from the generated (but not yet finalized) invoices.

### 4. Item Verification & Finalization
- **Branch-Specific Quantities:** Clicking an item on the Orders list opens a pop-up detail modal. This displays the exact quantity breakdown required for each branch (store/warehouse) on that specific trip.
- **Invoice Updating:** The user can update/verify the quantities and click **Save**. This action sends a request to the backend, finalizing the invoice for those branches on this trip and marking the item as completed.
- **Item Exclusion & Trip Rollover:**
  - Users can exclude an item completely from a trip. The Dashboard order list contains a **Ban/Exclude** icon for each item, which triggers a global exclusion for all branches on that trip after passing a visual **Confirmation Modal**.
  - Users can also exclude an item for a **single branch** via the Detail Modal. This also triggers the confirmation modal to prevent accidental skips.
  - When excluded, the system automatically locates the **next available trip** for that branch and rolls the item's quantity over. If no subsequent trip exists, the quantity requirement is permanently discarded.
- **UX Optimization (Auto-Sorting):** When the save resolves, the modal closes and the item is visually marked complete (turns green). To maintain a clean, actionable UX, completed items are automatically sorted to the bottom of the list, keeping pending actions pushed to the top.

### 5. Logout
- The user can log out at any time using the logout icon in the top header, which clears the session and returns them to the initial authentication screen.
