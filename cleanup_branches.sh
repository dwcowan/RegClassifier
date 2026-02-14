#!/bin/bash
#
# Branch Cleanup Script for RegClassifier
# Safely removes stale AI-generated branches
#

set -e

echo "=== RegClassifier Branch Cleanup ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fetch latest and prune
echo -e "${YELLOW}Fetching latest and pruning...${NC}"
git fetch --prune

# Count branches
TOTAL=$(git branch -r | grep -v HEAD | wc -l)
MERGED=$(git branch -r --merged origin/main | grep -v "HEAD\|main" | wc -l)
CODEX=$(git branch -r | grep -c "codex" || echo 0)
CLAUDE=$(git branch -r | grep -c "claude" || echo 0)

echo -e "${GREEN}Branch Statistics:${NC}"
echo "  Total remote branches: $TOTAL"
echo "  Merged to main: $MERGED"
echo "  Codex branches: $CODEX"
echo "  Claude branches: $CLAUDE"
echo ""

# Function to delete branches matching a pattern
delete_branches() {
    local pattern=$1
    local description=$2

    echo -e "${YELLOW}$description${NC}"
    branches=$(git branch -r | grep "$pattern" | sed 's|origin/||' | grep -v HEAD || true)

    if [ -z "$branches" ]; then
        echo "  No branches found matching: $pattern"
        return
    fi

    count=$(echo "$branches" | wc -l)
    echo "  Found $count branches"

    read -p "  Delete these branches? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$branches" | while IFS= read -r branch; do
            echo "    Deleting: $branch"
            git push origin --delete "$branch" 2>/dev/null || echo "      Failed (may not exist or no permission)"
        done
        echo -e "  ${GREEN}Done!${NC}"
    else
        echo "  Skipped."
    fi
    echo ""
}

# Delete merged branches first (safest)
delete_merged() {
    echo -e "${YELLOW}Step 1: Delete branches already merged to main${NC}"
    branches=$(git branch -r --merged origin/main | grep -v "HEAD\|main" | sed 's|origin/||' || true)

    if [ -z "$branches" ]; then
        echo "  No merged branches to delete"
        echo ""
        return
    fi

    count=$(echo "$branches" | wc -l)
    echo "  Found $count merged branches"
    echo ""
    echo "$branches" | head -10
    if [ $count -gt 10 ]; then
        echo "  ... and $(($count - 10)) more"
    fi
    echo ""

    read -p "  Delete all $count merged branches? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$branches" | while IFS= read -r branch; do
            echo "    Deleting: $branch"
            git push origin --delete "$branch" 2>/dev/null || echo "      Failed"
        done
        echo -e "  ${GREEN}Done!${NC}"
    else
        echo "  Skipped."
    fi
    echo ""
}

# Main cleanup workflow
echo "=== Cleanup Options ==="
echo ""

# Step 1: Delete merged branches
delete_merged

# Step 2: Delete old codex branches
delete_branches "origin/codex/" "Step 2: Delete old 'codex/' branches (AI-generated)"

# Step 3: Delete session-specific codex branches
delete_branches "origin/[a-z0-9]\{6\}-codex/" "Step 3: Delete session-specific codex branches (e.g., 'abc123-codex/...')"

# Step 4: Show remaining branches
echo -e "${YELLOW}Step 4: Review remaining branches${NC}"
remaining=$(git branch -r | grep -v HEAD | wc -l)
echo "  Remaining branches: $remaining"
echo ""

if [ $remaining -lt 50 ]; then
    echo "  Listing all remaining branches:"
    git branch -r | grep -v HEAD | sed 's|origin/||'
else
    echo "  Listing first 20 branches:"
    git branch -r | grep -v HEAD | head -20 | sed 's|origin/||'
    echo "  ... and $(($remaining - 20)) more"
fi

echo ""
echo -e "${GREEN}Cleanup complete!${NC}"
echo ""
echo "To manually delete a specific branch:"
echo "  git push origin --delete <branch-name>"
echo ""
echo "To delete ALL codex branches in one command (DANGEROUS!):"
echo "  git branch -r | grep 'origin/.*codex' | sed 's|origin/||' | xargs -I {} git push origin --delete {}"
