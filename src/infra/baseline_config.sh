#!/bin/bash
######## michaelkedey https://github.com/michaelkedey 25/02/2026 ##############
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
cat << EOF > inventory.ini
[servers]
EOF

echo "[servers]" > inventory.ini

terraform output -json vm_guest_ips | jq -r '
  to_entries[] | 
  . as $parent | 
  .value[] | 
  (.[]? // .) | 
  select(type == "string" and startswith("192.168.100.")) | 
  "\($parent.key) \(. )"
' | while read -r name ip; do
    if [ -n "$ip" ]; then
        echo "$name ansible_host=$ip ansible_user=admin" >> inventory.ini
        echo "Discovered and added: $name ($ip)"
    fi
done

echo ""
echo "Generated inventory.ini preview:"
cat inventory.ini
echo ""

echo "Running Ansible Playbook"
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.ini base-setup.yml --ask-become-pass

echo ""
if [ $? -eq 0 ]; then
    echo ""
    echo "Ansible hardening complete and successful!"
else
    echo ""
    echo "Ansible encountered errors during execution."
    exit 1
fi

