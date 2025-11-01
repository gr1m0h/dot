#!/bin/bash
#
# Test script for dotfiles installation using Docker
#
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Dotfiles Installation Test Suite ===${NC}"
echo ""

# Parse command line arguments
TEST_TYPE="${1:-all}"
INTERACTIVE="${2:-no}"

# Function to run a test
run_test() {
    local service=$1
    local description=$2
    
    echo -e "${YELLOW}Running test: ${description}${NC}"
    echo "----------------------------------------"
    
    if docker-compose -f test/docker-compose.yml run --rm "$service"; then
        echo -e "${GREEN}✓ Test passed${NC}"
    else
        echo -e "${RED}✗ Test failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    docker-compose -f test/docker-compose.yml down --remove-orphans
    docker-compose -f test/docker-compose.yml rm -f
}

# Set trap to clean up on exit
trap cleanup EXIT

# Change to repository root
cd "$(dirname "$0")/.."

# Build the Docker images
echo -e "${YELLOW}Building Docker images...${NC}"
docker-compose -f test/docker-compose.yml build

# Run tests based on the type
case "$TEST_TYPE" in
    ubuntu)
        run_test "ubuntu-test" "Ubuntu 22.04 Installation"
        ;;
    alpine)
        run_test "alpine-test" "Alpine Linux Installation"
        ;;
    interactive)
        echo -e "${YELLOW}Starting interactive test container...${NC}"
        echo "You can now test the installation manually."
        echo "To install dotfiles, run: sh /tmp/install.sh"
        echo ""
        docker-compose -f test/docker-compose.yml run --rm interactive
        ;;
    all)
        run_test "ubuntu-test" "Ubuntu 22.04 Installation"
        run_test "alpine-test" "Alpine Linux Installation"
        ;;
    *)
        echo -e "${RED}Unknown test type: $TEST_TYPE${NC}"
        echo "Usage: $0 [ubuntu|alpine|interactive|all]"
        exit 1
        ;;
esac

echo -e "${GREEN}=== All tests completed ===${NC}"