#!/bin/bash

cd ~/k3s/ansible

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
    local description=$1
    local command=$2
    local expected=$3

    result=$(eval "$command" 2>/dev/null)
    if echo "$result" | grep -q "$expected"; then
        printf "${GREEN}✓${NC} $description\n"
        ((PASS++))
    else
        printf "${RED}✗${NC} $description\n"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAIL++))
    fi
}

echo "================================"
echo " Verifying 02 — K3s cluster"
echo "================================"
echo ""

echo "--- K3s service ---"
check "K3s running on master" "ansible master -m shell -a 'systemctl is-active k3s'" "active"
check "K3s agent running on workers" "ansible workers -m shell -a 'systemctl is-active k3s-agent'" "active"

echo ""
echo "--- Cluster nodes ---"
check "Master node Ready"  "ansible master -m shell -a 'kubectl get nodes'" "master"
check "Worker1 node Ready" "ansible master -m shell -a 'kubectl get nodes'" "worker1"
check "Worker2 node Ready" "ansible master -m shell -a 'kubectl get nodes'" "worker2"
check "All nodes Ready"    "ansible master -m shell -a 'kubectl get nodes'" "Ready"

echo ""
echo "================================"
printf " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}\n"
echo "================================"