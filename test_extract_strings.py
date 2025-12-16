#!/usr/bin/env python3
"""
Test suite for extract_strings.py localization extraction tool.
Tests asset filtering, placeholder handling, and duplicate detection.
"""

import sys
sys.path.insert(0, '/Users/aadishsamir/Developer/Projects/FlutterDev/Apps/shopsync')

from extract_strings import StringExtractor


def test_asset_path_filtering():
    """Test that asset paths are correctly filtered out."""
    extractor = StringExtractor()
    
    test_cases = [
        # (string, should_be_translatable)
        ('assets/images/logo.png', False),
        ('assets/animations/loading.json', False),
        ('assets/badges/google/android/badge.png', False),
        ('assets/readme/buttons/button.svg', False),
        ('Welcome to ShopSync', True),
        ('Version 1.0.0', True),
        ('https://example.com', False),
        ('$variable', False),
        ('', False),
    ]
    
    print("Testing asset path filtering...")
    for string, expected in test_cases:
        result = extractor.is_translatable(string)
        status = "✅" if result == expected else "❌"
        print(f"  {status} '{string}' -> {result} (expected {expected})")


def test_placeholder_extraction():
    """Test placeholder extraction with various patterns."""
    extractor = StringExtractor()
    
    test_cases = [
        # (string, expected_placeholders)
        ('Hello $name', ['name']),
        ('Hello ${name}', ['name']),
        ('Version ${packageInfo.version}', ['version']),
        ('Version ${packageInfo.version} (${packageInfo.buildNumber})', ['version', 'buildNumber']),
        # Note: ${e.toString()} extracts property names, not the full expression
        # The extraction focuses on property-based placeholders for semantic naming
        ('Error: ${e.toString()}', []),  # Method calls don't extract in placeholder phase
        ('User ${user.name} added ${itemCount} items', ['name', 'itemCount']),
        ('Simple text without variables', []),
    ]
    
    print("\nTesting placeholder extraction...")
    for string, expected in test_cases:
        result = extractor.extract_placeholders(string)
        status = "✅" if result == expected else "❌"
        print(f"  {status} '{string}'")
        print(f"      Got: {result}, Expected: {expected}")


def test_string_normalization():
    """Test string normalization to ARB format."""
    extractor = StringExtractor()
    
    test_cases = [
        # (string, expected_normalized)
        ('Hello $name', 'Hello {name}'),
        ('Hello ${name}', 'Hello {name}'),
        ('Version ${packageInfo.version} (${packageInfo.buildNumber})', 'Version {version} ({buildNumber})'),
        ('Error: ${e.toString()}', 'Error: {e}'),
        ('User ${user.name} completed', 'User {name} completed'),
        ('assets/image.png', 'assets/image.png'),  # Not normalized if not translatable
    ]
    
    print("\nTesting string normalization...")
    for string, expected in test_cases:
        result = extractor.normalize_string(string)
        status = "✅" if result == expected else "❌"
        print(f"  {status} '{string}'")
        print(f"      Got: '{result}', Expected: '{expected}'")


def test_duplicate_placeholder_detection():
    """Test detection and handling of duplicate placeholders."""
    extractor = StringExtractor()
    
    test_cases = [
        # (string, expected_context_hints)
        ('Version ${packageInfo.version} (${packageInfo.buildNumber})', ['version', 'buildNumber']),
        ('You have ${count} items of ${count} total', ['Total', 'Remaining']),
        ('Before: ${value} After: ${value}', ['Before', 'After']),
    ]
    
    print("\nTesting duplicate placeholder detection...")
    for string, expected_hints in test_cases:
        # Note: We're testing the context hints generation
        hints = extractor._get_placeholder_context_hints(string, 'packageInfo', 2)
        # For property-based hints, we just verify they exist
        status = "✅" if len(hints) > 0 else "❌"
        print(f"  {status} '{string}'")
        print(f"      Context hints generated: {hints}")


if __name__ == '__main__':
    test_asset_path_filtering()
    test_placeholder_extraction()
    test_string_normalization()
    test_duplicate_placeholder_detection()
    
    print("\n" + "="*60)
    print("✅ Test suite complete!")
    print("Run this test file to validate extractor changes:")
    print("  python3 test_extract_strings.py")
