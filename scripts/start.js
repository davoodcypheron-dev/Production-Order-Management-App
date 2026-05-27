const { spawn } = require('child_process');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const serverDir = path.join(rootDir, 'server');
const clientDir = path.join(rootDir, 'client');

console.log('🚀 Starting Nexus Prod Application...\n');

// Start Backend
const server = spawn('npm', ['start'], {
    cwd: serverDir,
    shell: true,
    stdio: 'pipe'
});

server.stdout.on('data', (data) => {
    console.log(`[SERVER]: ${data.toString().trim()}`);
});

server.stderr.on('data', (data) => {
    console.error(`[SERVER ERROR]: ${data.toString().trim()}`);
});

// Start Frontend
const client = spawn('npm', ['run', 'dev'], {
    cwd: clientDir,
    shell: true,
    stdio: 'pipe'
});

client.stdout.on('data', (data) => {
    console.log(`[CLIENT]: ${data.toString().trim()}`);
});

client.stderr.on('data', (data) => {
    console.error(`[CLIENT ERROR]: ${data.toString().trim()}`);
});

// Handle exit
process.on('SIGINT', () => {
    console.log('\nStopping Nexus Prod Application...');
    server.kill();
    client.kill();
    process.exit();
});
