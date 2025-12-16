#!/usr/bin/env python3
"""
ShopSync String Extraction Tool for Weblate Localization
Extracts translatable strings from Dart files and generates app_en.arb
Supports variable placeholders, type hints, and descriptions
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple
import argparse


class StringExtractor:
    def __init__(self, lib_dir: str = "lib", output_file: str = "lib/l10n/app_en.arb"):
        self.lib_dir = Path(lib_dir)
        self.output_file = Path(output_file)
        self.strings: Dict[str, Dict] = {}
        self.seen_keys: Set[str] = set()
        
        # Patterns for extracting strings
        self.patterns = [
            # Text widget: Text('string') or Text("string")
            r'''Text\s*\(\s*['"]([^'"]+)['"]\s*\)''',
            # Text with variables: Text('Hello $name') or Text('Hello ${user.name}')
            r'''Text\s*\(\s*['"]([^'"]*\$[^'"]+)['"]\s*\)''',
            # title property
            r'''title\s*:\s*['"]([^'"]+)['"]''',
            # title with variables
            r'''title\s*:\s*['"]([^'"]*\$[^'"]+)['"]''',
            # return statement strings
            r'''return\s+['"]([^'"]+)['"]''',
            # return with variables
            r'''return\s+['"]([^'"]*\$[^'"]+)['"]''',
            # label property
            r'''label\s*:\s*['"]([^'"]+)['"]''',
            # label with variables
            r'''label\s*:\s*['"]([^'"]*\$[^'"]+)['"]''',
            # SnackBar content
            r'''content\s*:\s*(?:const\s+)?Text\s*\(\s*['"]([^'"]+)['"]\s*\)''',
            # content with variables
            r'''content\s*:\s*(?:const\s+)?Text\s*\(\s*['"]([^'"]*\$[^'"]+)['"]\s*\)''',
            # hintText property
            r'''hintText\s*:\s*['"]([^'"]+)['"]''',
            # hintText with variables
            r'''hintText\s*:\s*['"]([^'"]*\$[^'"]+)['"]''',
            # labelText property
            r'''labelText\s*:\s*['"]([^'"]+)['"]''',
            # labelText with variables
            r'''labelText\s*:\s*['"]([^'"]*\$[^'"]+)['"]''',
        ]

    def extract_placeholders(self, text: str) -> List[str]:
        """Extract variable placeholders from a string."""
        placeholders = []
        
        # Match ${variable.property} or ${variable.method()} - extract base variable only
        complex_matches = re.findall(r'\$\{([A-Za-z_][A-Za-z0-9_]*)[\.\(][^\}]*\}', text)
        placeholders.extend(complex_matches)
        
        # Match ${variable} pattern (simple variable)
        simple_braces = re.findall(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}', text)
        placeholders.extend(simple_braces)
        
        # Match $variable pattern (not followed by {)
        simple_dollar = re.findall(r'\$([A-Za-z_][A-Za-z0-9_]*)(?!\{)', text)
        placeholders.extend(simple_dollar)
        
        # Remove duplicates while preserving order
        seen = set()
        cleaned = []
        for ph in placeholders:
            # Clean: take only the base variable name before any dot or parenthesis
            clean_ph = re.split(r'[\.\(]', ph)[0]
            # Strip leading underscores which are common for private fields
            clean_ph = clean_ph.lstrip('_')
            if clean_ph and clean_ph not in seen:
                seen.add(clean_ph)
                cleaned.append(clean_ph)
        
        return cleaned

    def normalize_string(self, text: str) -> str:
        """Normalize string for ARB format."""
        # First, handle complex expressions with property access/method calls
        # ${obj.property} or ${obj.method()} -> {obj}
        normalized = re.sub(r'\$\{([A-Za-z_][A-Za-z0-9_]*)[\.\(][^\}]*\}', r'{\1}', text)
        
        # Convert simple Dart interpolation to ARB placeholders
        # ${variable} -> {variable}
        normalized = re.sub(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}', r'{\1}', normalized)
        # $variable -> {variable}
        normalized = re.sub(r'\$([A-Za-z_][A-Za-z0-9_]*)(?!\{)', r'{\1}', normalized)

        # Remove leading underscores inside placeholders
        normalized = re.sub(r'\{_([A-Za-z0-9_]+)\}', r'{\1}', normalized)
        
        return normalized

    def string_to_key(self, text: str) -> str:
        """Convert a string to a valid ARB key (camelCase)."""
        # Remove special characters except spaces
        clean = re.sub(r'[^a-zA-Z0-9\s]', '', text)
        
        # Split by spaces
        words = clean.split()
        
        if not words:
            return "empty"
        
        # First word lowercase, rest title case
        key = words[0].lower()
        for word in words[1:]:
            key += word.capitalize()
        
        # Ensure uniqueness
        original_key = key
        counter = 1
        while key in self.seen_keys:
            key = f"{original_key}{counter}"
            counter += 1
        
        self.seen_keys.add(key)
        return key

    def extract_from_file(self, file_path: Path) -> None:
        """Extract strings from a single Dart file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            for pattern in self.patterns:
                matches = re.finditer(pattern, content)
                for match in matches:
                    text = match.group(1)
                    
                    # Skip empty strings
                    if not text.strip():
                        continue
                    
                    # Skip strings that are just variables or code
                    if text.strip().startswith('$') and ' ' not in text:
                        continue
                    
                    # Skip URLs
                    if text.startswith('http://') or text.startswith('https://'):
                        continue
                    
                    # Extract placeholders
                    placeholders = self.extract_placeholders(text)
                    
                    # Normalize string
                    normalized = self.normalize_string(text)
                    
                    # Generate key
                    key = self.string_to_key(text)
                    
                    # Build entry
                    entry = {
                        "value": normalized,
                        "file": str(file_path.relative_to(self.lib_dir.parent))
                    }
                    
                    if placeholders:
                        entry["placeholders"] = placeholders # pyright: ignore[reportArgumentType]
                    
                    self.strings[key] = entry
                    
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

    def extract_all(self) -> None:
        """Extract strings from all Dart files in lib directory."""
        dart_files = []
        for dart_file in self.lib_dir.rglob("*.dart"):
            # Skip generated localization files to avoid self-reinclusion and duplication
            if "l10n" in dart_file.parts and dart_file.name.startswith("app_localizations"):
                continue
            dart_files.append(dart_file)
        print(f"🔍 Scanning {len(dart_files)} Dart files...")
        
        for dart_file in dart_files:
            self.extract_from_file(dart_file)
        
        print(f"✅ Extracted {len(self.strings)} unique strings")

    def generate_arb(self) -> None:
        """Generate the ARB file."""
        arb_content = {
            "@@locale": "en"
        }
        
        # Sort keys alphabetically for consistency
        sorted_keys = sorted(self.strings.keys())
        
        for key in sorted_keys:
            entry = self.strings[key]
            
            # Add the string value
            arb_content[key] = entry["value"]
            
            # Add metadata if there are placeholders
            if "placeholders" in entry and entry["placeholders"]:
                metadata = {
                    "placeholders": {}
                }
                
                for placeholder in entry["placeholders"]:
                    metadata["placeholders"][placeholder] = {
                        "type": "String"
                    }
                
                # Add description showing source file
                metadata["description"] = f"From: {entry['file']}" # pyright: ignore[reportArgumentType]
                
                arb_content[f"@{key}"] = metadata # pyright: ignore[reportArgumentType]
        
        # Ensure output directory exists
        self.output_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Write ARB file with proper formatting
        with open(self.output_file, 'w', encoding='utf-8') as f:
            json.dump(arb_content, f, indent=2, ensure_ascii=False)
        
        print(f"📝 Generated {self.output_file}")
        
        # Count strings with variables
        strings_with_vars = sum(1 for s in self.strings.values() if "placeholders" in s)
        print(f"   - {len(self.strings)} total strings")
        print(f"   - {strings_with_vars} strings with variables")
        print(f"   - {len(self.strings) - strings_with_vars} simple strings")


def main():
    parser = argparse.ArgumentParser(
        description="Extract translatable strings from Flutter app for Weblate"
    )
    parser.add_argument(
        "--lib-dir",
        default="lib",
        help="Path to lib directory (default: lib)"
    )
    parser.add_argument(
        "--output",
        default="lib/l10n/app_en.arb",
        help="Output ARB file path (default: lib/l10n/app_en.arb)"
    )
    parser.add_argument(
        "--stats",
        action="store_true",
        help="Show detailed statistics"
    )
    
    args = parser.parse_args()
    
    print("🌍 ShopSync String Extraction for Weblate")
    print("=" * 50)
    
    extractor = StringExtractor(args.lib_dir, args.output)
    extractor.extract_all()
    extractor.generate_arb()
    
    if args.stats:
        print("\n📊 Statistics:")
        print(f"   Total unique strings: {len(extractor.strings)}")
        
        # Count by file
        file_counts = {}
        for entry in extractor.strings.values():
            file_name = entry['file'].split('/')[1] if '/' in entry['file'] else entry['file']
            file_counts[file_name] = file_counts.get(file_name, 0) + 1
        
        print("\n   Top 10 files by string count:")
        for file, count in sorted(file_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"      {file}: {count}")
    
    print("\n✨ Done! Ready for Weblate translation.")


if __name__ == "__main__":
    main()
