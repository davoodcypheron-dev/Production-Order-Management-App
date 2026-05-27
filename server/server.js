// c:/Users/devda/source/repos/anti-gra/Production-Order-Management-App/server/server.js
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

// Load env vars if any
dotenv.config();

// Determine Database service (Mock vs MySQL)
const db = require('./db');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    const result = await db.loginUser(username, password);
    if (result.success) {
        res.json(result);
    } else {
        res.status(401).json(result);
    }
});

app.get('/api/sections', async (req, res) => {
    const sections = await db.getSections();
    res.json({ sections });
});

app.get('/api/trips/:section', async (req, res) => {
    const { section } = req.params;
    const trips = await db.getTrips(section);
    res.json({ trips });
});

app.get('/api/orders/:section/:trip', async (req, res) => {
    const { section, trip } = req.params;
    const orders = await db.getOrders(section, trip);
    res.json({ orders });
});

app.post('/api/orders/update', async (req, res) => {
    const { itemId, trip, newDistribution } = req.body;

    if (!itemId || !trip || !newDistribution) {
        return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const result = await db.updateInvoice(itemId, trip, newDistribution);
    if (result.success) {
        res.json(result);
    } else {
        res.status(500).json(result);
    }
});

app.post('/api/orders/exclude', async (req, res) => {
    const { section, itemId, currentTrip, branch } = req.body;

    if (!section || !itemId || !currentTrip) {
        return res.status(400).json({ success: false, message: "Missing required fields for exclusion" });
    }

    // Branch can be null/undefined to exclude entirely
    const result = await db.excludeItem(section, itemId, currentTrip, branch);
    if (result.success) {
        res.json(result);
    } else {
        res.status(500).json(result);
    }
});

app.post('/api/config', (req, res) => {
    try {
        const configPath = path.join(__dirname, 'db_config.json');

        // Read existing structure
        let currentConfig = { use_mock_db: true, config: {} };
        if (fs.existsSync(configPath)) {
            const fileData = fs.readFileSync(configPath, 'utf8');
            currentConfig = JSON.parse(fileData);
        }

        // Merge with incoming req.body 
        // req.body should have: host, port, database, user, password, use_mock_db
        currentConfig.config = {
            host: req.body.host || currentConfig.config.host,
            port: Number(req.body.port) || currentConfig.config.port,
            user: req.body.user || currentConfig.config.user,
            password: req.body.password || currentConfig.config.password,
            database: req.body.database || currentConfig.config.database
        };

        if (req.body.use_mock_db !== undefined) {
            currentConfig.use_mock_db = req.body.use_mock_db;
        } else {
            // Let UI decide, typically false if they configure DB
            currentConfig.use_mock_db = false;
        }

      

        fs.writeFileSync(configPath, JSON.stringify(currentConfig, null, 2), 'utf8');
        res.json({ success: true, message: 'Configuration saved successfully. Please restart server if needed.' });
    } catch (error) {
        console.error('Config Save Error:', error);
        res.status(500).json({ success: false, message: 'Failed to write configuration file' });
    }
});

app.post('/api/test-db', async (req, res) => {
    try {
        const { host, port, user, password, database } = req.body;

        // Create a temporary connection
        const connection = await mysql.createConnection({
            host,
            port: Number(port),
            user,
            password,
            database
        });

        await connection.ping();
        await connection.end();
        res.json({ success: true, message: 'Database connection successful!' });
    } catch (error) {
        console.error('Test DB Error:', error);
        res.json({ success: false, message: error.message || 'Database connection failed' });
    }
});

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || "localhost";

app.listen(PORT, () => {
    console.log(`\n================================`);
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`================================`);
});
