#!/bin/bash
######## michaelkedey https://github.com/michaelkedey 19/08/2026 ##############
set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND"; exit 1' ERR
set -x

echo "Extracting and filtering IP addresses from Terraform state"

# Make sure jq is installed
if ! command -v jq &> /dev/null; then
    echo "'jq' is required but not installed. Please install it first."
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "'ansible-playbook' is not installed. Please install Ansible first."
    exit 1
fi

echo "Generating structured inventory.ini"
cat << EOF > dbs.ini
[servers]
EOF

echo "[servers]" > dbs.ini

terraform output -json vm_guest_ips | jq -r '
  to_entries[] |
  . as $parent |
  .value[] |
  (.[]? // .) |
  select(
    type == "string"
    and startswith("192.168.100.")
    and ($parent.key | startswith("db"))
  ) |
  "\($parent.key) \(. )"
' | while read -r name ip; do

    if [ -n "$ip" ]; then
        echo "$name ansible_host=$ip ansible_user=admin" >> dbs.ini
        echo "Discovered and added: $name ($ip)"
    fi

done

echo ""
echo "Generated dbs.ini preview:"
cat dbs.ini
echo ""

echo "Running Ansible Playbook"
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i dbs.ini postgres-setup.yml --ask-become-pass

echo ""
if [ $? -eq 0 ]; then
    echo ""
    echo "Postgres install complete and successful!"
else
    echo ""
    echo "Postgres install encountered errors during execution."
    exit 1
fi

