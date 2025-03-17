#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing addon-atascado Helm chart${NC}"
echo -e "${YELLOW}=================================${NC}"

# Create test namespace
TEST_NS="atascado-test"
echo -e "\n${GREEN}Creating test namespace: $TEST_NS${NC}"
kubectl create namespace $TEST_NS 2>/dev/null || true

# Test 1: Non-matching magic words (should complete)
echo -e "\n${GREEN}Test 1: Non-matching magic words (should complete)${NC}"
echo "Installing chart with magicWord1=abracadabra, magicWord2=hocus-pocus"
helm upgrade --install atascado-test1 . \
  --namespace $TEST_NS \
  --set magicWord1=abracadabra \
  --set magicWord2=hocus-pocus \
  --wait --timeout 60s || echo -e "${RED}Timeout waiting for release to complete (expected to succeed)${NC}"

echo -e "\n${GREEN}Checking job status:${NC}"
kubectl get jobs -n $TEST_NS atascado-job
echo -e "\n${GREEN}Job logs:${NC}"
kubectl logs job/atascado-job -n $TEST_NS

# Clean up first test
echo -e "\n${GREEN}Cleaning up first test${NC}"
helm uninstall atascado-test1 -n $TEST_NS
kubectl delete job atascado-job -n $TEST_NS --ignore-not-found

# Test 2: Matching magic words (should get stuck)
echo -e "\n${GREEN}Test 2: Matching magic words (should get stuck)${NC}"
echo "Installing chart with magicWord1=abracadabra, magicWord2=abracadabra"
helm upgrade --install atascado-test2 . \
  --namespace $TEST_NS \
  --set magicWord1=abracadabra \
  --set magicWord2=abracadabra \
  --wait --timeout 30s || echo -e "${YELLOW}Timeout waiting for release to complete (expected behavior for stuck job)${NC}"

echo -e "\n${GREEN}Checking job status:${NC}"
kubectl get jobs -n $TEST_NS atascado-job
echo -e "\n${GREEN}Job logs:${NC}"
kubectl logs job/atascado-job -n $TEST_NS

# Don't clean up second test automatically so user can inspect
echo -e "\n${GREEN}Test complete!${NC}"
echo -e "${YELLOW}The second test job is still running. To clean up:${NC}"
echo "kubectl delete job atascado-job -n $TEST_NS"
echo "helm uninstall atascado-test2 -n $TEST_NS"
echo "kubectl delete namespace $TEST_NS"
