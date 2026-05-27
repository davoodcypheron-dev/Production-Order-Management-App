// c:/Users/devda/source/repos/anti-gra/Production-Order-Management-App/server/db/mysql_db.js
const mysql = require('mysql2/promise');
const configData = require('../db_config.json');

// Global connection pool
let pool = null;

async function getPool() {
    if (!pool) {
        pool = mysql.createPool({
            host: configData.config.host,
            user: configData.config.user,
            password: configData.config.password,
            database: configData.config.database,
            port: configData.config.port,
            waitForConnections: true,
            connectionLimit: 10,
            queueLimit: 0
        });
    }
    return pool;
}

// ---------------------------------------------------------
// The following assumes you have corresponding Stored Procedures
// in your MySQL database. e.g. CALL sp_loginUser(?, ?)
// ---------------------------------------------------------

async function loginUser(username, password) {
    try {
        const db = await getPool();
        // CALL sp_LoginUser(@username, @password)
        const [rows] = await db.execute('CALL sp_LoginUser(?, ?)', [username, password]);
        // SP returns the first result set in rows[0]
        if (rows[0] && rows[0].length > 0) {
            return { success: true, user: rows[0][0].username };
        }
        return { success: false, message: "Invalid credentials" };
    } catch (error) {
        console.error("DB Login Error:", error);
        return { success: false, message: "Database connection failed" };
    }
}

async function getSections() {
    try {
        const db = await getPool();
        const [rows] = await db.execute('CALL sp_GetSections()');
        // Expecting SP to return [{ section: "Fresh Bakery" }, ...]
        return rows[0].map(row => row.section);
    } catch (error) {
        console.error("DB getSections Error:", error);
        return [];
    }
}

async function getTrips(section) {
    try {
        const db = await getPool();
        const [rows] = await db.execute('CALL sp_GetTripsBySection(?)', [section]);
        // Expecting SP to return [{ trip: "06:00 AM Trip" }, ...]
        return rows[0].map(row => row.trip);
    } catch (error) {
        console.error("DB getTrips Error:", error);
        return [];
    }
}

async function getOrders(section, trip) {
    try {
        const db = await getPool();
        // This SP should probably return a flat list or grouped data.
        // For simplicity, let's assume it returns flat rows that we group.
        // e.g. [{ id: 101, name: "Artisan Sourdough", unit: "Loaf", branch: "Main Warehouse", qty: 45, isCompleted: 0 }]

        const [rows] = await db.execute('CALL sp_GetOrders(?, ?)', [section, trip]);
        const data = rows[0];

        // Group the flat row data into the structure expected by the frontend
        const itemsMap = new Map();

        data.forEach(row => {
            if (!itemsMap.has(row.id)) {
                itemsMap.set(row.id, {
                    id: row.id,
                    name: row.name,
                    unit: row.unit,
                    isCompleted: Boolean(row.isCompleted), // 1 or 0
                    distribution: []
                });
            }

            itemsMap.get(row.id).distribution.push({
                branch: row.branch,
                trip: trip,
                qty: row.qty
            });
        });

        return Array.from(itemsMap.values()).sort((a, b) => a.isCompleted - b.isCompleted);
    } catch (error) {
        console.error("DB getOrders Error:", error);
        return [];
    }
}

async function updateInvoice(itemId, trip, newDistribution) {
    try {
        const db = await getPool();

        // This process might involve starting a transaction and looping through
        // the newDistribution list to update the quantities, then marking it completed.
        // We'll assume a SP that takes a JSON string, or we call a SP in a loop.

        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            // Update individual quantities
            for (const dist of newDistribution) {
                await connection.execute('CALL sp_UpdateOrderQty(?, ?, ?, ?)', [itemId, trip, dist.branch, dist.qty]);
            }
            // Mark trip item as completed
            await connection.execute('CALL sp_MarkOrderComplete(?, ?)', [itemId, trip]);

            await connection.commit();
            connection.release();
            return { success: true, message: `Invoice updated in MySQL for item ${itemId}` };

        } catch (txnError) {
            await connection.rollback();
            connection.release();
            throw txnError;
        }

    } catch (error) {
        console.error("DB updateInvoice Error:", error);
        return { success: false, message: "Failed to update database" };
    }
}

async function excludeItem(section, itemId, currentTrip, branch) {
    try {
        const db = await getPool();
        
        // Let SQL stored procedure handle moving the logic
        // We pass null for branch if we want to exclude for all branches
        await db.execute('CALL sp_ExcludeOrderItem(?, ?, ?, ?)', [
            section, 
            itemId, 
            currentTrip, 
            branch || null
        ]);
        
        return { success: true, message: `Successfully excluded item from trip.` };
    } catch (error) {
        console.error("DB excludeItem Error:", error);
        return { success: false, message: "Failed to exclude item in database" };
    }
}

module.exports = {
    loginUser,
    getSections,
    getTrips,
    getOrders,
    updateInvoice,
    excludeItem
};
