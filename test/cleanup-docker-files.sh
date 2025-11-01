#!/bin/bash
#
# Cleanup script to remove Docker-related test files
# Run this to remove files that are no longer needed for macOS-only testing
#

echo "This will remove the following Docker-related test files:"
echo "- test/Dockerfile"
echo "- test/docker-compose.yml"
echo "- test/test.sh"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f test/Dockerfile
    rm -f test/docker-compose.yml
    rm -f test/test.sh
    echo "Docker-related files removed."
else
    echo "Cleanup cancelled."
fi