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
echo " Verifying 03 — PostgreSQL"
echo "================================"
echo ""

echo "--- PostgreSQL service ---"
check "PostgreSQL running" "ansible database -m shell -a 'systemctl is-active postgresql'" "active"

echo ""
echo "--- PostgreSQL listening ---"
check "Listening on all interfaces" "ansible database -m shell -a 'ss -tlnp | grep 5432'" "0.0.0.0"

echo ""
echo "--- Database objects ---"
check "coursedb exists" "ansible database -m shell -a 'sudo -u postgres psql -lqt'" "coursedb"
check "visits table exists" "ansible database -m shell -a 'sudo -u postgres psql -d coursedb -c \"\dt\"'" "visits"

echo ""
echo "--- pg_hba.conf ---"
check "Host network allowed" "ansible database -m shell -a 'cat /etc/postgresql/14/main/pg_hba.conf'" "192.168.56.0"
check "Pod network allowed" "ansible database -m shell -a 'cat /etc/postgresql/14/main/pg_hba.conf'" "10.42.0.0"

echo ""
echo "================================"
printf " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}\n"
echo "================================"