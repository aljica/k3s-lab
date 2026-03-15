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
echo " Verifying 04 — Flask on K3s"
echo "================================"
echo ""

echo "--- Flask endpoints ---"
check "Flask / on master"   "curl -s http://192.168.56.11:30000/"  "Hello from K3s"
check "Flask / on worker1"  "curl -s http://192.168.56.12:30000/"  "Hello from K3s"
check "Flask / on worker2"  "curl -s http://192.168.56.13:30000/"  "Hello from K3s"

echo ""
echo "--- Flask /visit ---"
check "Visit endpoint works" "curl -s http://192.168.56.11:30000/visit" "serving this request"
check "DB recording visits"  "curl -s http://192.168.56.11:30000/visit" "visits"

echo ""
echo "--- K3s deployment ---"
check "Flask deployment exists"  "ansible master -m shell -a 'kubectl get deployment flask'" "flask"
check "4 replicas running"       "ansible master -m shell -a 'kubectl get deployment flask'" "4/4"

echo ""
echo "--- Pods on all nodes ---"
check "Pod on master"   "ansible master -m shell -a 'kubectl get pods -o wide'" "master"
check "Pod on worker1"  "ansible master -m shell -a 'kubectl get pods -o wide'" "worker1"
check "Pod on worker2"  "ansible master -m shell -a 'kubectl get pods -o wide'" "worker2"

echo ""
echo "--- Load balancing ---"
check "Multiple pods serving" "for i in {1..10}; do curl -s http://192.168.56.11:30000/visit | head -1; done" "flask"

echo ""
echo "--- Database ---"
check "Visits recorded in DB" "ansible database -b -m shell -a 'sudo -u postgres psql -d coursedb -c \"SELECT COUNT(*) FROM visits\"'" "row"

echo ""
echo "================================"
printf " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}\n"
echo "================================"