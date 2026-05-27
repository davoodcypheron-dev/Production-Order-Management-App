// c:/Users/devda/source/repos/anti-gra/Production-Order-Management-App/server/db/mock_db.js

// Hardcoded data from original index.html
const orderData = {
    "Fresh Bakery": [
        {
            id: 101,
            name: "Artisan Sourdough",
            unit: "Loaf",
            distribution: [
                { branch: "Main Warehouse", trip: "06:00 AM Trip", qty: 45 },
                { branch: "North Side Hub", trip: "06:00 AM Trip", qty: 30 },
                { branch: "South Terminal", trip: "09:00 AM Trip", qty: 25 },
                { branch: "Downtown Store", trip: "12:00 PM Trip", qty: 10 },
                { branch: "West End Plaza", trip: "03:00 PM Trip", qty: 15 },
                { branch: "Airport Outlet", trip: "06:00 PM Trip", qty: 20 }
            ]
        },
        {
            id: 102,
            name: "Butter Croissant",
            unit: "Pack",
            distribution: [
                { branch: "West End Plaza", trip: "09:00 AM Trip", qty: 40 },
                { branch: "Skyline Mall", trip: "09:00 AM Trip", qty: 12 },
                { branch: "Main Warehouse", trip: "06:00 AM Trip", qty: 45 },
                { branch: "North Side Hub", trip: "12:00 PM Trip", qty: 18 }
            ]
        },
        {
            id: 103,
            name: "Chocolate Danish",
            unit: "Pack",
            distribution: [
                { branch: "Downtown Store", trip: "06:00 AM Trip", qty: 50 },
                { branch: "Campus Point", trip: "09:00 AM Trip", qty: 25 },
                { branch: "Airport Outlet", trip: "12:00 PM Trip", qty: 30 }
            ]
        },
        {
            id: 104,
            name: "Baguette",
            unit: "Loaf",
            distribution: [
                { branch: "South Terminal", trip: "06:00 AM Trip", qty: 60 },
                { branch: "West End Plaza", trip: "09:00 AM Trip", qty: 40 },
                { branch: "Skyline Mall", trip: "12:00 PM Trip", qty: 20 }
            ]
        }
    ],

    "Beverages": [
        {
            id: 401,
            name: "Cold Brew Coffee",
            unit: "Bottle",
            distribution: [
                { branch: "Campus Point", trip: "09:00 AM Trip", qty: 80 },
                { branch: "Downtown Store", trip: "09:00 AM Trip", qty: 60 },
                { branch: "Skyline Mall", trip: "12:00 PM Trip", qty: 35 },
                { branch: "Airport Outlet", trip: "03:00 PM Trip", qty: 40 }
            ]
        },
        {
            id: 402,
            name: "Orange Juice",
            unit: "Bottle",
            distribution: [
                { branch: "Main Warehouse", trip: "06:00 AM Trip", qty: 120 },
                { branch: "North Side Hub", trip: "09:00 AM Trip", qty: 80 },
                { branch: "South Terminal", trip: "12:00 PM Trip", qty: 60 }
            ]
        },
        {
            id: 403,
            name: "Lemon Soda",
            unit: "Bottle",
            distribution: [
                { branch: "Downtown Store", trip: "09:00 AM Trip", qty: 70 },
                { branch: "West End Plaza", trip: "12:00 PM Trip", qty: 40 },
                { branch: "Campus Point", trip: "03:00 PM Trip", qty: 50 }
            ]
        }
    ],

    "Dairy Products": [
        {
            id: 501,
            name: "Fresh Milk",
            unit: "Ltr",
            distribution: [
                { branch: "Main Warehouse", trip: "06:00 AM Trip", qty: 200 },
                { branch: "North Side Hub", trip: "06:00 AM Trip", qty: 150 },
                { branch: "South Terminal", trip: "09:00 AM Trip", qty: 120 },
                { branch: "Downtown Store", trip: "12:00 PM Trip", qty: 90 }
            ]
        },
        {
            id: 502,
            name: "Greek Yogurt",
            unit: "Cup",
            distribution: [
                { branch: "Skyline Mall", trip: "09:00 AM Trip", qty: 60 },
                { branch: "Campus Point", trip: "12:00 PM Trip", qty: 50 },
                { branch: "Airport Outlet", trip: "03:00 PM Trip", qty: 45 }
            ]
        }
    ],

    "Snacks": [
        {
            id: 601,
            name: "Salted Pretzels",
            unit: "Pack",
            distribution: [
                { branch: "West End Plaza", trip: "09:00 AM Trip", qty: 100 },
                { branch: "Downtown Store", trip: "12:00 PM Trip", qty: 80 },
                { branch: "Campus Point", trip: "03:00 PM Trip", qty: 60 }
            ]
        },
        {
            id: 602,
            name: "Potato Chips",
            unit: "Pack",
            distribution: [
                { branch: "Main Warehouse", trip: "06:00 AM Trip", qty: 140 },
                { branch: "North Side Hub", trip: "09:00 AM Trip", qty: 100 },
                { branch: "Skyline Mall", trip: "12:00 PM Trip", qty: 90 }
            ]
        }
    ]
};

// Internal state to mock "completed" items per trip
let completedMockItems = new Set();

const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function loginUser(username, password) {
    await wait(800); // Simulate network latency
    if (username === "admin" && password === "1234") {
        return { success: true, user: username };
    }
    return { success: false, message: "Invalid credentials" };
}

async function getSections() {
    await wait(300);
    return Object.keys(orderData);
}

async function getTrips(section) {
    await wait(300);
    if (!orderData[section]) return [];
    const trips = new Set();
    orderData[section].forEach(item => {
        item.distribution.forEach(d => trips.add(d.trip));
    });
    return Array.from(trips).sort();
}

async function getOrders(section, trip) {
    await wait(600);
    const allItems = orderData[section] || [];

    // Filter items that have distribution for this trip
    const itemsForTrip = allItems.filter(item =>
        item.distribution.some(d => d.trip === trip)
    );

    // Attach mock completed status
    const result = itemsForTrip.map(item => ({
        ...item,
        // Only return distribution for the specific trip requested
        distribution: item.distribution.filter(d => d.trip === trip),
        isCompleted: completedMockItems.has(`${item.id}-${trip}`)
    }));

    return result.sort((a, b) => a.isCompleted - b.isCompleted);
}

async function updateInvoice(itemId, trip, newDistribution) {
    await wait(600);

    // In a real app we'd update the database quantities here.
    // For mock, we simply mark this item-trip combination as completed.
    completedMockItems.add(`${itemId}-${trip}`);

    return { success: true, message: `Invoice updated for item ${itemId} on ${trip}` };
}

async function excludeItem(section, itemId, currentTrip, branch) {
    await wait(600);

    // Find the section items
    const allItems = orderData[section];
    if (!allItems) return { success: false, message: "Section not found" };

    // Find the specific item
    const item = allItems.find(i => i.id === itemId);
    if (!item) return { success: false, message: "Item not found" };

    // Determine the next trip for rollover
    const tripsSet = new Set();
    allItems.forEach(i => i.distribution.forEach(d => tripsSet.add(d.trip)));
    const sortedTrips = Array.from(tripsSet).sort();

    const currentTripIndex = sortedTrips.indexOf(currentTrip);
    const nextTrip = currentTripIndex >= 0 && currentTripIndex < sortedTrips.length - 1
        ? sortedTrips[currentTripIndex + 1]
        : null;

    // Filter which distributions to modify based on "branch" parameter
    // If branch is provided, find only that distribution. If null, get all for currentTrip.
    const distToModify = item.distribution.filter(d =>
        d.trip === currentTrip && (!branch || d.branch === branch)
    );

    if (distToModify.length === 0) {
        return { success: false, message: "No matching distribution found for exclusion." };
    }

    // Apply the exclusion/rollover
    distToModify.forEach(dist => {
        if (nextTrip) {
            // Roll over to the next available trip
            dist.trip = nextTrip;
        } else {
            // No next trip exists, we completely remove this distribution from the array
            item.distribution = item.distribution.filter(d => d !== dist);
        }
    });

    return {
        success: true,
        message: nextTrip
            ? `Excluded from ${currentTrip}. Rolled over to ${nextTrip}.`
            : `Excluded from ${currentTrip}. Item removed completely as no next trip exists.`
    };
}

module.exports = {
    loginUser,
    getSections,
    getTrips,
    getOrders,
    updateInvoice,
    excludeItem
};
