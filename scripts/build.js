// scripts/build.js
const path = require('path');
const { exec } = require('pkg');

console.log('📦 Packaging application into executable...');

const rootDir = path.resolve(__dirname, '..');
const packageJsonPath = path.join(rootDir, 'server', 'package.json');
const outputPath = path.join(rootDir, 'dist', 'nexus-prod.exe');

exec([packageJsonPath, '-o', outputPath])
    .then(() => {
        console.log('✅ Standalone executable successfully built at:');
        console.log(outputPath);
    })
    .catch((err) => {
        console.error('❌ Failed to package executable:', err);
        process.exit(1);
    });
