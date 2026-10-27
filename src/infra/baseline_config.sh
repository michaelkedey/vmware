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

terraform output -json vm_guest_ips | jq -r '
  to_entries[] | 
  . as $parent | 
  .value[] | 
  (.[]? // .) | 
  select(type == "string" and startswith("192.168.100.")) | 
  "\($parent.key) \(. )"
' | while read -r name ip; do
    if [ -n "$ip" ]; then
        echo "$name ansible_host=$ip ansible_user=pbx" >> inventory.ini
        echo "Discovered and added: $name ($ip)"
    fi
done

echo ""
echo "Generated inventory.ini preview:"
cat inventory.ini
echo ""

# --- INTERACTIVE OS SELECTOR ---
echo "========================================="
echo "Select the Target Operating System:"
echo "1) Rocky Linux / RHEL / CentOS"
echo "2) Debian / Ubuntu"
echo "========================================="
read -p "Enter choice [1 or 2]: " os_choice

case $os_choice in
    1)
        PLAYBOOK="base-setup-rocky.yml"
        echo "Selected Rocky/RHEL playbook."
        ;;
    2)
        PLAYBOOK="base-setup-debian.yml"
        echo "Selected Debian/Ubuntu playbook."
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Running Ansible Playbook: $PLAYBOOK"
export ANSIBLE_HOST_KEY_CHECKING=False

# Runs the chosen playbook
ansible-playbook -i inventory.ini "$PLAYBOOK" --ask-become-pass

echo ""
if [ $? -eq 0 ]; then
    echo ""
    echo "Ansible hardening complete and successful!"
else
    echo ""
    echo "Ansible encountered errors during execution."
    exit 1
fi
