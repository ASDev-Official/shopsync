#!/bin/bash

# ShopSync Test Runner Script
# Runs all tests with coverage reporting

set -e

echo "🧪 ShopSync Test Suite Runner"
echo "=============================="

# Check if coverage package is available
if ! flutter pub global list 2>/dev/null | grep -q 'coverage'; then
  echo "📦 Installing coverage package..."
  flutter pub global activate coverage
fi

echo ""
echo "🔄 Running Flutter tests with coverage..."
echo "=========================================="

# Run tests with coverage
flutter test --coverage --reporter json --reporter expanded

echo ""
echo "📊 Generating coverage report..."
echo "=================================="

# Generate LCOV report from coverage data
if command -v lcov &> /dev/null; then
  lcov --summary coverage/lcov.info
  echo ""
  echo "✅ Coverage report generated successfully"
else
  echo "⚠️  lcov not found. Install it to generate coverage summaries."
  echo "   On macOS: brew install lcov"
  echo "   On Ubuntu: sudo apt-get install lcov"
fi

echo ""
echo "📁 Coverage files location: coverage/lcov.info"
echo ""
echo "✨ All tests completed successfully!"
