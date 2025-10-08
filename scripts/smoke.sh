#!/bin/bash
# smoke.sh - Execute smoke tests (30-60s, 1-2 RPS) for quick validation
# Usage: ./scripts/smoke.sh [UC_ID|domain|all]
# Examples:
#   ./scripts/smoke.sh UC001        # Run UC001 only
#   ./scripts/smoke.sh products     # Run all products smoke tests
#   ./scripts/smoke.sh all          # Run all 8 smoke tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
K6_RPS=${K6_RPS:-1}
K6_DURATION=${K6_DURATION:-30s}
RESULTS_DIR="results/smoke/$(date +%Y%m%d_%H%M%S)"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}k6 Smoke Tests - Quick Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "RPS: ${GREEN}${K6_RPS}${NC}"
echo -e "Duration: ${GREEN}${K6_DURATION}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Function to run a single smoke test
run_smoke_test() {
    local uc_id=$1
    local test_name=$2
    local test_file=$3
    
    echo -e "${YELLOW}Running Smoke Test: ${test_name} (${uc_id})${NC}"
    
    if K6_RPS=$K6_RPS K6_DURATION=$K6_DURATION \
       k6 run \
       --out json="${RESULTS_DIR}/${uc_id}_smoke.json" \
       --summary-export="${RESULTS_DIR}/${uc_id}_summary.json" \
       "$test_file"; then
        echo -e "${GREEN}✅ ${uc_id} PASSED${NC}\n"
        return 0
    else
        echo -e "${RED}❌ ${uc_id} FAILED${NC}\n"
        return 1
    fi
}

# Test definitions (UC_ID, Name, File)
declare -A TESTS=(
    # Products
    ["UC001"]="Browse Products Catalog|tests/api/products/browse-catalog.test.ts"
    ["UC004"]="View Product Details|tests/api/products/view-details.test.ts"
    
    # Auth
    ["UC003"]="User Login & Profile|tests/api/auth/user-login-profile.test.ts"
    
    # Carts
    ["UC005"]="Cart Operations Read|tests/api/carts/cart-operations-read.test.ts"
    
    # Users
    ["UC008"]="List Users Admin|tests/api/users/list-users-admin.test.ts"
    
    # Posts
    ["UC013"]="Content Moderation|tests/api/posts/content-moderation.test.ts"
    
    # Jornadas
    ["UC009"]="User Journey Unauthenticated|tests/scenarios/user-journey-unauthenticated.test.ts"
)

# Domain groupings
PRODUCTS_UCS=("UC001" "UC004")
AUTH_UCS=("UC003")
CARTS_UCS=("UC005")
USERS_UCS=("UC008")
POSTS_UCS=("UC013")
JORNADAS_UCS=("UC009")
ALL_UCS=("UC001" "UC004" "UC003" "UC005" "UC008" "UC013" "UC009")

# Determine which tests to run
TARGET=${1:-all}
TESTS_TO_RUN=()

case $TARGET in
    UC[0-9][0-9][0-9])
        # Specific UC
        if [[ -n "${TESTS[$TARGET]}" ]]; then
            TESTS_TO_RUN=("$TARGET")
        else
            echo -e "${RED}Error: Unknown UC ${TARGET}${NC}"
            exit 1
        fi
        ;;
    products)
        TESTS_TO_RUN=("${PRODUCTS_UCS[@]}")
        ;;
    auth)
        TESTS_TO_RUN=("${AUTH_UCS[@]}")
        ;;
    carts)
        TESTS_TO_RUN=("${CARTS_UCS[@]}")
        ;;
    users)
        TESTS_TO_RUN=("${USERS_UCS[@]}")
        ;;
    posts)
        TESTS_TO_RUN=("${POSTS_UCS[@]}")
        ;;
    jornadas)
        TESTS_TO_RUN=("${JORNADAS_UCS[@]}")
        ;;
    all)
        TESTS_TO_RUN=("${ALL_UCS[@]}")
        ;;
    *)
        echo -e "${RED}Error: Unknown target '${TARGET}'${NC}"
        echo "Usage: $0 [UC_ID|domain|all]"
        echo "  UC_ID: UC001, UC003, UC004, UC005, UC008, UC009, UC013"
        echo "  domain: products, auth, carts, users, posts, jornadas"
        echo "  all: run all smoke tests"
        exit 1
        ;;
esac

# Run tests
PASSED=0
FAILED=0
START_TIME=$(date +%s)

for UC_ID in "${TESTS_TO_RUN[@]}"; do
    IFS='|' read -r TEST_NAME TEST_FILE <<< "${TESTS[$UC_ID]}"
    
    if run_smoke_test "$UC_ID" "$TEST_NAME" "$TEST_FILE"; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Smoke Tests Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Duration: ${GREEN}${DURATION}s${NC}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Exit with error if any test failed
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Some tests failed. Check results in ${RESULTS_DIR}${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All smoke tests passed!${NC}"
    exit 0
fi
