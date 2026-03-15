#!/bin/bash

# Change to ansible directory so ansible.cfg is found
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
        echo -e "${GREEN}✓${NC} $description"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $description"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAIL++))
    fi
}

echo "================================"
echo " Verifying 01 — VM connectivity"
echo "================================"
echo ""

echo "--- Ansible ping ---"
check "Master reachable"   "ansible master   -m ping" "pong"
check "Workers reachable"  "ansible workers  -m ping" "pong"
check "Database reachable" "ansible database -m ping" "pong"

echo ""
echo "--- SSH connectivity ---"
check "Master SSH"   "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa vagrant@192.168.56.11 echo ok" "ok"
check "Worker1 SSH"  "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa vagrant@192.168.56.12 echo ok" "ok"
check "Worker2 SSH"  "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa vagrant@192.168.56.13 echo ok" "ok"
check "Database SSH" "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa vagrant@192.168.56.14 echo ok" "ok"

echo ""
echo "================================"
echo " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "================================"