#!/bin/bash
# soak.sh - Execute soak tests (60-120min, 10 RPS sustained) for stability validation
# Usage: ./scripts/soak.sh [UC_ID|domain|mixed|all]
# Examples:
#   ./scripts/soak.sh UC001      # Run UC001 only (60 min)
#   ./scripts/soak.sh products   # Run products soak test
#   ./scripts/soak.sh mixed      # Run UC011 mixed workload (60 min)
#   ./scripts/soak.sh all        # Run all 4 soak tests (240 min total)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
K6_RPS=${K6_RPS:-10}
K6_DURATION=${K6_DURATION:-60m}
RESULTS_DIR="results/soak/$(date +%Y%m%d_%H%M%S)"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}k6 Soak Tests - Stability Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}⚠️  WARNING: Long-running tests (60+ min each)${NC}"
echo -e "RPS: ${GREEN}${K6_RPS} (sustained)${NC}"
echo -e "Duration: ${GREEN}${K6_DURATION}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Confirmation prompt
read -p "Continue with soak tests? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Soak tests cancelled.${NC}"
    exit 0
fi

# Function to run a single soak test
run_soak_test() {
    local uc_id=$1
    local test_name=$2
    local test_file=$3
    local custom_rps=${4:-$K6_RPS}
    
    echo -e "${YELLOW}Running Soak Test: ${test_name} (${uc_id}) @ ${custom_rps} RPS for ${K6_DURATION}${NC}"
    echo -e "${YELLOW}⏱️  Estimated completion: $(date -d "+${K6_DURATION}" "+%H:%M:%S")${NC}"
    
    if K6_RPS=$custom_rps K6_DURATION=$K6_DURATION \
       k6 run \
       --out json="${RESULTS_DIR}/${uc_id}_soak.json" \
       --summary-export="${RESULTS_DIR}/${uc_id}_summary.json" \
       "$test_file"; then
        echo -e "${GREEN}✅ ${uc_id} PASSED (stable over time)${NC}\n"
        return 0
    else
        echo -e "${RED}❌ ${uc_id} FAILED (degradation detected)${NC}\n"
        return 1
    fi
}

# Test definitions (UC_ID, Name, File, Custom_RPS)
declare -A TESTS=(
    # Products (memory leak detection)
    ["UC001"]="Browse Products Catalog|tests/api/products/browse-catalog.test.ts|10"
    
    # Auth (session management)
    ["UC012"]="Token Refresh & Session|tests/api/auth/token-refresh.test.ts|5"
    
    # Jornadas (realistic traffic 24/7)
    ["UC011"]="Mixed Workload Realistic|tests/scenarios/mixed-workload.test.ts|10"
)

# Domain groupings
PRODUCTS_UCS=("UC001")
AUTH_UCS=("UC012")
MIXED_UCS=("UC011")
ALL_UCS=("UC001" "UC012" "UC011")

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
    mixed)
        TESTS_TO_RUN=("${MIXED_UCS[@]}")
        ;;
    all)
        TESTS_TO_RUN=("${ALL_UCS[@]}")
        ;;
    *)
        echo -e "${RED}Error: Unknown target '${TARGET}'${NC}"
        echo "Usage: $0 [UC_ID|domain|mixed|all]"
        echo "  UC_ID: UC001, UC012, UC011"
        echo "  domain: products, auth"
        echo "  mixed: run UC011 only (realistic 24/7 traffic)"
        echo "  all: run all soak tests (240 min total)"
        exit 1
        ;;
esac

# Calculate total estimated time
TOTAL_TESTS=${#TESTS_TO_RUN[@]}
DURATION_SECONDS=$(echo "$K6_DURATION" | sed 's/m/*60/' | sed 's/h/*3600/' | bc)
TOTAL_DURATION=$((TOTAL_TESTS * DURATION_SECONDS))
TOTAL_MINUTES=$((TOTAL_DURATION / 60))

echo -e "${BLUE}Estimated total duration: ${TOTAL_MINUTES} minutes ($(($TOTAL_MINUTES / 60))h $(($TOTAL_MINUTES % 60))m)${NC}"
echo ""

# Run tests
PASSED=0
FAILED=0
START_TIME=$(date +%s)

for UC_ID in "${TESTS_TO_RUN[@]}"; do
    IFS='|' read -r TEST_NAME TEST_FILE CUSTOM_RPS <<< "${TESTS[$UC_ID]}"
    
    if run_soak_test "$UC_ID" "$TEST_NAME" "$TEST_FILE" "$CUSTOM_RPS"; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Soak Tests Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Duration: ${GREEN}${DURATION}s ($(($DURATION / 60))m / $(($DURATION / 3600))h)${NC}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "Results: ${GREEN}${RESULTS_DIR}${NC}"
echo ""

# Analyze trends
echo -e "${BLUE}Analyzing stability trends...${NC}"
for UC_ID in "${TESTS_TO_RUN[@]}"; do
    JSON_FILE="${RESULTS_DIR}/${UC_ID}_soak.json"
    if [ -f "$JSON_FILE" ]; then
        # Extract P95 latencies over time (simplified analysis)
        echo -e "${YELLOW}${UC_ID} Trend Analysis:${NC}"
        echo "  (Full analysis requires external tools like k6-reporter or Grafana)"
        echo "  Raw data: ${JSON_FILE}"
    fi
done

# Exit with error if any test failed
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Some tests showed degradation over time. Check results in ${RESULTS_DIR}${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All soak tests passed with stable performance!${NC}"
    exit 0
fi
