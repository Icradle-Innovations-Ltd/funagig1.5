#!/usr/bin/env node

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import http from 'http';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('🚀 Starting FunaGig Development Server...\n');

// Check if XAMPP is running
const checkXAMPP = () => {
  return new Promise((resolve) => {
    // Note: Using HTTP for local development check only
    const req = http.get('http://localhost:80', (res) => {
      console.log('✅ Apache is running on port 80');
      resolve(true);
    });
    
    req.on('error', () => {
      console.log('❌ Apache is not running on port 80');
      console.log('   Please start Apache and ensure it is running on port 80');
      resolve(false);
    });
    
    req.setTimeout(3000, () => {
      console.log('❌ Apache connection timeout');
      resolve(false);
    });
  });
};

// Start Vite dev server
const startVite = () => {
  console.log('🎯 Starting Vite development server...');
  
  const vite = spawn('npx', ['vite'], {
    stdio: 'inherit',
    shell: true,
    cwd: __dirname
  });
  
  vite.on('error', (err) => {
    console.error('❌ Failed to start Vite:', err.message);
    process.exit(1);
  });
  
  vite.on('close', (code) => {
    console.log(`Vite process exited with code ${code}`);
  });
  
  // Handle process termination
  process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down development server...');
    vite.kill('SIGINT');
    process.exit(0);
  });
};

// Main execution
const main = async () => {
  console.log('🔍 Checking XAMPP status...');
  const xamppRunning = await checkXAMPP();
  
  if (!xamppRunning) {
    console.log('\n⚠️  Warning: Apache is not running. The frontend will work, but API calls will fail.');
    console.log('   To fix this:');
    console.log('   1. Start XAMPP Control Panel');
    console.log('   2. Start Apache service');
    console.log('   3. Ensure Apache is running on port 80\n');
  }
  
  console.log('📦 Installing dependencies if needed...');
  
  // Check if node_modules exists
  const fs = await import('fs');
  if (!fs.existsSync(join(__dirname, 'node_modules'))) {
    console.log('📥 Installing dependencies...');
    const install = spawn('npm', ['install'], {
      stdio: 'inherit',
      shell: true,
      cwd: __dirname
    });
    
    install.on('close', (code) => {
      if (code === 0) {
        console.log('✅ Dependencies installed successfully');
        startVite();
      } else {
        console.error('❌ Failed to install dependencies');
        process.exit(1);
      }
    });
  } else {
    startVite();
  }
};

main().catch(console.error);
