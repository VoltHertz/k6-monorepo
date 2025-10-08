#!/bin/bash
# stress.sh - Execute stress tests (10-15min, 20-50 RPS ramping) for load validation
# Usage: ./scripts/stress.sh [UC_ID|domain|mixed|all]
# Examples:
#   ./scripts/stress.sh UC001      # Run UC001 only
#   ./scripts/stress.sh products   # Run all products stress tests
#   ./scripts/stress.sh mixed      # Run UC011 mixed workload
#   ./scripts/stress.sh all        # Run all 6 stress tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
K6_RPS_START=${K6_RPS_START:-5}
K6_RPS_PEAK=${K6_RPS_PEAK:-50}
K6_DURATION=${K6_DURATION:-15m}
RESULTS_DIR="results/stress/$(date +%Y%m%d_%H%M%S)"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}k6 Stress Tests - Load Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "RPS Range: ${GREEN}${K6_RPS_START} → ${K6_RPS_PEAK}${NC}"
echo -e "Duration: ${GREEN}${K6_DURATION}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Function to run a single stress test
run_stress_test() {
    local uc_id=$1
    local test_name=$2
    local test_file=$3
    local rps_start=${4:-$K6_RPS_START}
    local rps_peak=${5:-$K6_RPS_PEAK}
    
    echo -e "${YELLOW}Running Stress Test: ${test_name} (${uc_id}) @ ${rps_start}→${rps_peak} RPS${NC}"
    
    if K6_RPS_START=$rps_start K6_RPS_PEAK=$rps_peak K6_DURATION=$K6_DURATION \
       k6 run \
       --out json="${RESULTS_DIR}/${uc_id}_stress.json" \
       --summary-export="${RESULTS_DIR}/${uc_id}_summary.json" \
       "$test_file"; then
        echo -e "${GREEN}✅ ${uc_id} PASSED (degradation acceptable)${NC}\n"
        return 0
    else
        echo -e "${RED}❌ ${uc_id} FAILED (excessive degradation)${NC}\n"
        return 1
    fi
}

# Test definitions (UC_ID, Name, File, RPS_Start, RPS_Peak)
declare -A TESTS=(
    # Products (high priority)
    ["UC001"]="Browse Products Catalog|tests/api/products/browse-catalog.test.ts|5|50"
    ["UC002"]="Search & Filter Products|tests/api/products/search-products.test.ts|5|35"
    
    # Auth (critical)
    ["UC003"]="User Login & Profile|tests/api/auth/user-login-profile.test.ts|5|30"
    
    # Carts (write operations)
    ["UC006"]="Cart Operations Write|tests/api/carts/cart-operations-write.test.ts|5|25"
    
    # Jornadas (realistic traffic)
    ["UC011"]="Mixed Workload Realistic|tests/scenarios/mixed-workload.test.ts|10|50"
)

# Domain groupings
PRODUCTS_UCS=("UC001" "UC002")
AUTH_UCS=("UC003")
CARTS_UCS=("UC006")
MIXED_UCS=("UC011")
ALL_UCS=("UC001" "UC002" "UC003" "UC006" "UC011")

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
    mixed)
        TESTS_TO_RUN=("${MIXED_UCS[@]}")
        ;;
    all)
        TESTS_TO_RUN=("${ALL_UCS[@]}")
        ;;
    *)
        echo -e "${RED}Error: Unknown target '${TARGET}'${NC}"
        echo "Usage: $0 [UC_ID|domain|mixed|all]"
        echo "  UC_ID: UC001, UC002, UC003, UC006, UC011"
        echo "  domain: products, auth, carts"
        echo "  mixed: run UC011 only (realistic traffic)"
        echo "  all: run all stress tests"
        exit 1
        ;;
esac

# Run tests
PASSED=0
FAILED=0
START_TIME=$(date +%s)

for UC_ID in "${TESTS_TO_RUN[@]}"; do
    IFS='|' read -r TEST_NAME TEST_FILE RPS_START RPS_PEAK <<< "${TESTS[$UC_ID]}"
    
    if run_stress_test "$UC_ID" "$TEST_NAME" "$TEST_FILE" "$RPS_START" "$RPS_PEAK"; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Stress Tests Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Duration: ${GREEN}${DURATION}s ($(($DURATION / 60))m $(($DURATION % 60))s)${NC}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Exit with error if any test failed
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Some tests exceeded acceptable degradation. Check results in ${RESULTS_DIR}${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All stress tests passed with acceptable degradation!${NC}"
    exit 0
fi
