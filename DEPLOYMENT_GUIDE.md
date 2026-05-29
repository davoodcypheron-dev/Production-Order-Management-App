# Deployment & Windows Service Installation Guide

This guide explains how to compile the Production Order Management Application into a single standalone executable (`nexus-prod.exe`) and install it as a Windows Service so it runs continuously in the background and starts automatically when the system boots.

---

## Architecture Overview

1. **Unified Application**: The React frontend (`client`) is built into static assets and packaged directly inside the executable. The Express backend (`server`) serves these static assets on the root path `/` and serves the API on `/api`.
2. **Local Network Ready**: The server binds to `0.0.0.0` (all network interfaces) and the client uses relative API paths (`/api`). This ensures the app can be accessed from other computers on your local network using the host's IP address (e.g. `http://192.168.1.100:5000`) without breaking API calls.
3. **External Configuration**: When packaged, the database connection config (`db_config.json`) is placed outside the binary (in the same folder as the `.exe` file) so it remains writable and customizable via the settings page.

---

## Step 1: Install Dependencies & Build the Executable

To compile the application, you need **Node.js** installed on your system.

1. Open PowerShell or Command Prompt in the project root directory.
2. Install all dependencies for both the client and server:
   ```bash
   npm run install-all
   ```
3. Compile the React client and package the executable:
   ```bash
   npm run build:exe
   ```

Upon completion, you will find the compiled standalone binary at:
`[Project Root]/dist/nexus-prod.exe`

---

## Step 2: Install as a Windows Service

We use **WinSW** (Windows Service Wrapper), a robust and widely used wrapper, to register our executable with the Windows Service Control Manager.

### Option A: Automated PowerShell Setup (Recommended)

1. Open PowerShell **as Administrator** (right-click PowerShell -> *Run as Administrator*).
2. Navigate to the project root directory.
3. Run the setup script:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\scripts\setup-service.ps1
   ```
4. The script will automatically download WinSW, write the service XML configuration, and prompt you to install and start the service.

### Option B: Manual Installation

If you prefer to set up the service manually, follow these steps:

1. Create a folder where you want the service to run (e.g., `C:\Program Files\NexusProd`).
2. Copy `dist/nexus-prod.exe` to this folder.
3. Download the WinSW wrapper from GitHub:
   - Go to [WinSW Releases](https://github.com/winsw/winsw/releases) and download `WinSW-x64.exe` (or `WinSW-x86.exe` for 32-bit systems).
   - Place this file in your service folder and rename it to `nexus-prod-service.exe`.
4. Create a configuration file named `nexus-prod-service.xml` in the same folder with the following content:
   ```xml
   <service>
     <id>NexusProdService</id>
     <name>Nexus Prod Order Management Service</name>
     <description>Runs the Nexus Production Order Management application on port 5000.</description>
     <executable>%BASE%\nexus-prod.exe</executable>
     <log mode="roll"/>
     <onfailure action="restart" delay="10 sec"/>
   </service>
   ```
5. Open Command Prompt or PowerShell **as Administrator** and navigate to your service folder.
6. Install and start the service:
   ```cmd
   nexus-prod-service.exe install
   nexus-prod-service.exe start
   ```

---

## Step 3: Verify and Access the Application

### Accessing the UI
- **Local Access**: Open your browser and navigate to [http://localhost:5000](http://localhost:5000).
- **Local Network Access**: Find the host computer's IP address (run `ipconfig` in Command Prompt) and access it from other devices on the same network using:
  `http://[Host-IP-Address]:5000` (e.g., `http://192.168.1.100:5000`).

### Service Controls
You can manage the service using the standard Windows Services manager (`services.msc`, look for **Nexus Prod Order Management Service**) or using the command-line commands below (run as Administrator):

| Action | WinSW wrapper command | Standard Windows command | PowerShell command |
| :--- | :--- | :--- | :--- |
| **Start** | `.\nexus-prod-service.exe start` | `net start NexusProdService` | `Start-Service NexusProdService` |
| **Stop** | `.\nexus-prod-service.exe stop` | `net stop NexusProdService` | `Stop-Service NexusProdService` |
| **Restart** | `.\nexus-prod-service.exe restart` | N/A | `Restart-Service NexusProdService` |
| **Status** | `.\nexus-prod-service.exe status` | `sc query NexusProdService` | `Get-Service NexusProdService` |
| **Uninstall** | `.\nexus-prod-service.exe uninstall` | N/A | N/A |

---

## Step 4: Configuring the Database

1. The first time the application runs, it will create a `db_config.json` file in the same directory as `nexus-prod.exe`.
2. To configure your database, open the application in a browser, navigate to the database settings tab, enter your MySQL server credentials, test the connection, and click **Save**.
3. **Restart the Service** to apply database settings:
   - In PowerShell (Admin): `Restart-Service NexusProdService`
   - Or by stopping and starting via Windows Services Manager.
