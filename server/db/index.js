// c:/Users/devda/source/repos/anti-gra/Production-Order-Management-App/server/db/index.js
const fs = require('fs');
const path = require('path');
const mock_db = require('./mock_db');
const mysql_db = require('./mysql_db');

// Read the configuration to decide which DB service to use
const configPath = path.join(__dirname, '../db_config.json');

function getDBService() {
    try {
        const rawConfig = fs.readFileSync(configPath);
        const config = JSON.parse(rawConfig);

        if (config.use_mock_db) {
            console.log("\n[DB SERVICE] Using MOCK Database\n");
            return mock_db;
        } else {
            console.log("\n[DB SERVICE] Using REAL MySQL Database\n");
            return mysql_db;
        }
    } catch (error) {
        console.error("Failed to read db_config.json, falling back to MOCK DB:", error);
        return mock_db;
    }
}

// Export the determined DB service
module.exports = getDBService();
