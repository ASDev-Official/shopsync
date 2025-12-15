#!/bin/bash

# Create l10n directory if it doesn't exist
mkdir -p lib/l10n

# Initialize ARB file with locale
echo '{
  "@@locale": "en",' > lib/l10n/app_en.arb

# Find all Dart files and extract string literals from Text(), title:, and return statements (single or double quoted).
# Handles escaped characters within the string literal.
read -r -d '' PERL_EXTRACT <<'PERL'
while(/Text\(["']((?:\\.|[^"'])+?)["']\)/sg){print "$1\n"}
while(/title:\s*["']((?:\\.|[^"'])+?)["']/sg){print "$1\n"}
while(/return\s*["']((?:\\.|[^"'])+?)["']/sg){print "$1\n"}
PERL

ALL_STRINGS=$(find lib -name "*.dart" -type f -print0 | \
  xargs -0 perl -0777 -ne "$PERL_EXTRACT" | sort -u)

# Convert strings to ARB format
while IFS= read -r line; do
    if [ ! -z "$line" ]; then
      # Convert "Welcome to App" to "welcomeToApp"
      key=$(echo "$line" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-zA-Z0-9 ]//g' | awk '{for(i=1;i<=NF;i++)if(i==1)printf "%s", $i; else printf "%s", toupper(substr($i,1,1)) substr($i,2)}')

      # Clean up the string and normalize interpolation to ARB placeholders
      cleaned_string=$(printf '%s' "$line" | perl -pe 's/\\\$/\$/g')
      normalized_string=$(printf '%s' "$cleaned_string" | perl -pe "s/\\$\\{?([A-Za-z_][A-Za-z0-9_]*)\\}?/{\\1}/g; s/\\\\\\$\\{([A-Za-z_][A-Za-z0-9_]*)\\}/{\\1}/g; s/\\\\\\$([A-Za-z_][A-Za-z0-9_]*)/{\\1}/g; s/\\\\'/""/g")

        # Drop strings with mismatched braces or dotted placeholders that can't form valid ARB placeholders
        braces_open=$(printf '%s' "$normalized_string" | grep -o '{' | wc -l | tr -d ' ')
        braces_close=$(printf '%s' "$normalized_string" | grep -o '}' | wc -l | tr -d ' ')
        if [ "$braces_open" -ne "$braces_close" ]; then
          continue
        fi
        if printf '%s' "$normalized_string" | grep -Eq '{[^}]*\.[^}]*}'; then
          continue
        fi
        if printf '%s' "$normalized_string" | grep -Eq '}\.'; then
          continue
        fi

        # Skip duplicate keys (keep first occurrence)
        if grep -q "\"$key\": " lib/l10n/app_en.arb; then
          continue
        fi

      # Escape backslashes and double quotes for valid JSON
      escaped_string=$(printf '%s' "$normalized_string" | perl -pe 's/\\/\\\\/g; s/"/\\"/g')

      # Detect variables used in the string for ARB metadata
      placeholders=$(printf '%s' "$cleaned_string" | perl -ne 'while(/\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?/g){print "$1\n"} while(/\\\$\{([A-Za-z_][A-Za-z0-9_]*)\}/g){print "$1\n"} while(/\\\$([A-Za-z_][A-Za-z0-9_]*)/g){print "$1\n"}' | sort -u)

      echo "  \"$key\": \"$escaped_string\"," >> lib/l10n/app_en.arb

      if [ ! -z "$placeholders" ]; then
        echo "  \"@$key\": {" >> lib/l10n/app_en.arb
        echo "    \"placeholders\": {" >> lib/l10n/app_en.arb

        placeholder_array=()
        while IFS= read -r ph; do
          placeholder_array+=("$ph")
        done <<< "$placeholders"
        for idx in "${!placeholder_array[@]}"; do
          name="${placeholder_array[$idx]}"
          if [ "$idx" -lt "$((${#placeholder_array[@]} - 1))" ]; then
            comma="," 
          else
            comma=""
          fi
          echo "      \"$name\": {}$comma" >> lib/l10n/app_en.arb
        done

        echo "    }" >> lib/l10n/app_en.arb
        echo "  }," >> lib/l10n/app_en.arb
      fi
    fi
done <<< "$ALL_STRINGS"

# Close the JSON object by trimming the final trailing comma
perl -0777 -i -pe 's/,\s*\n(?=\s*})/\n/' lib/l10n/app_en.arb
echo "}" >> lib/l10n/app_en.arb

# Count entries
COUNT=$(grep -c ":" lib/l10n/app_en.arb)
echo "Generated app_en.arb with $((COUNT - 1)) strings"
