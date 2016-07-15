#!/bin/sh

# Read each line in
while IFS= read -r line; do
  # Only assess lines containing the URL, and print URL to output
  printf '%s\n' "$line" | grep 'URL:https' | sed -e 's/^.*URL:\([^ ]*\).*$/\1/'
done
