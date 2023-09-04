#!/bin/bash
cd .infra/terraform/ && terraform apply -auto-approve
cd ../ansible && ansible-playbook --vault-password-file pass_for_vault -i inventory ansible.yml