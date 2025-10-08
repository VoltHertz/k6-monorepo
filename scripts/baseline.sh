#!/bin/bash
# baseline.sh - Execute baseline tests (5-10min, 5-10 RPS) for SLO validation
# Usage: ./scripts/baseline.sh [UC_ID|domain|all]
# Examples:
#   ./scripts/baseline.sh UC001      # Run UC001 only
#   ./scripts/baseline.sh products   # Run all products baseline tests
#   ./scripts/baseline.sh all        # Run all 11 baseline tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
K6_RPS=${K6_RPS:-5}
K6_DURATION=${K6_DURATION:-5m}
RESULTS_DIR="results/baseline/$(date +%Y%m%d_%H%M%S)"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}k6 Baseline Tests - SLO Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "RPS: ${GREEN}${K6_RPS}${NC}"
echo -e "Duration: ${GREEN}${K6_DURATION}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Function to run a single baseline test
run_baseline_test() {
    local uc_id=$1
    local test_name=$2
    local test_file=$3
    local custom_rps=${4:-$K6_RPS}
    
    echo -e "${YELLOW}Running Baseline Test: ${test_name} (${uc_id}) @ ${custom_rps} RPS${NC}"
    
    if K6_RPS=$custom_rps K6_DURATION=$K6_DURATION \
       k6 run \
       --out json="${RESULTS_DIR}/${uc_id}_baseline.json" \
       --summary-export="${RESULTS_DIR}/${uc_id}_summary.json" \
       "$test_file"; then
        echo -e "${GREEN}✅ ${uc_id} PASSED${NC}\n"
        return 0
    else
        echo -e "${RED}❌ ${uc_id} FAILED (SLO violation)${NC}\n"
        return 1
    fi
}

# Test definitions (UC_ID, Name, File, Custom_RPS)
declare -A TESTS=(
    # Products
    ["UC001"]="Browse Products Catalog|tests/api/products/browse-catalog.test.ts|5"
    ["UC002"]="Search & Filter Products|tests/api/products/search-products.test.ts|5"
    ["UC004"]="View Product Details|tests/api/products/view-details.test.ts|5"
    ["UC007"]="Browse by Category|tests/api/products/browse-catalog.test.ts|5"  # Same file as UC001
    
    # Auth
    ["UC003"]="User Login & Profile|tests/api/auth/user-login-profile.test.ts|5"
    ["UC012"]="Token Refresh & Session|tests/api/auth/token-refresh.test.ts|3"
    
    # Carts
    ["UC005"]="Cart Operations Read|tests/api/carts/cart-operations-read.test.ts|5"
    ["UC006"]="Cart Operations Write|tests/api/carts/cart-operations-write.test.ts|3"
    
    # Users
    ["UC008"]="List Users Admin|tests/api/users/list-users-admin.test.ts|2"
    
    # Posts
    ["UC013"]="Content Moderation|tests/api/posts/content-moderation.test.ts|2"
    
    # Jornadas
    ["UC009"]="User Journey Unauthenticated|tests/scenarios/user-journey-unauthenticated.test.ts|6"
    ["UC010"]="User Journey Authenticated|tests/scenarios/user-journey-authenticated.test.ts|3"
)

# Domain groupings
PRODUCTS_UCS=("UC001" "UC002" "UC004" "UC007")
AUTH_UCS=("UC003" "UC012")
CARTS_UCS=("UC005" "UC006")
USERS_UCS=("UC008")
POSTS_UCS=("UC013")
JORNADAS_UCS=("UC009" "UC010")
ALL_UCS=("UC001" "UC002" "UC004" "UC007" "UC003" "UC012" "UC005" "UC006" "UC008" "UC013" "UC009" "UC010")

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
        echo "  UC_ID: UC001-UC013 (see docs/casos_de_uso/)"
        echo "  domain: products, auth, carts, users, posts, jornadas"
        echo "  all: run all baseline tests"
        exit 1
        ;;
esac

# Run tests
PASSED=0
FAILED=0
START_TIME=$(date +%s)

for UC_ID in "${TESTS_TO_RUN[@]}"; do
    IFS='|' read -r TEST_NAME TEST_FILE CUSTOM_RPS <<< "${TESTS[$UC_ID]}"
    
    if run_baseline_test "$UC_ID" "$TEST_NAME" "$TEST_FILE" "$CUSTOM_RPS"; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Baseline Tests Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Duration: ${GREEN}${DURATION}s ($(($DURATION / 60))m $(($DURATION % 60))s)${NC}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Exit with error if any test failed
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Some tests failed SLO validation. Check results in ${RESULTS_DIR}${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All baseline tests passed SLO validation!${NC}"
    exit 0
fi
