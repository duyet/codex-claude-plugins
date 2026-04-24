#!/bin/bash
# Fetch Duyet's knowledge data from llms.txt sources
# Usage: ./scripts/fetch-duyet-data.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_DIR="$(dirname "$SCRIPT_DIR")/knowledge"
DATA_FILE="$KNOWLEDGE_DIR/_raw_data.txt"

# Sources
SOURCES=(
  "https://duyet.net/llms.txt|Main Profile"
  "https://cv.duyet.net/llms.txt|Resume/CV"
  "https://blog.duyet.net/llms.txt|Blog Archive"
)

echo -e "${BLUE}[1/4] Creating knowledge directory...${NC}"
mkdir -p "$KNOWLEDGE_DIR"

echo -e "${BLUE}[2/4] Fetching llms.txt sources...${NC}"
: > "$DATA_FILE"

for source in "${SOURCES[@]}"; do
  IFS='|' read -r url name <<< "$source"
  echo -e "${GREEN}Fetching: $name${NC}"
  echo "## $name" >> "$DATA_FILE"
  curl -s "$url" >> "$DATA_FILE"
  echo -e "\n" >> "$DATA_FILE"
done

echo -e "${BLUE}[3/4] Data fetched to: $DATA_FILE${NC}"
echo -e "${BLUE}[4/4] Next steps:${NC}"
echo "  1. Review the fetched data"
echo "  2. Update knowledge/duyet-profile.md with new info"
echo "  3. Update knowledge/blog-archive.md if needed"
echo "  4. Commit with semantic commit message"
echo ""
echo -e "${GREEN}Done!${NC}"
