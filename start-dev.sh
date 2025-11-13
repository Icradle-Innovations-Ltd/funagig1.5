#!/bin/bash

echo "Starting FunaGig Development Server..."
echo

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not available"
    exit 1
fi

echo "Node.js version:"
node --version
echo "npm version:"
npm --version
echo

# Start the development server
node dev-server.js
