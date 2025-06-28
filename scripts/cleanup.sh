#!/bin/bash
read -p "⚠️ Esto eliminará todos los recursos creados con Terraform. ¿Deseas continuar? (s/n): " confirm
if [[ "$confirm" != "s" ]]; then
  echo "❌ Cancelado."
  exit 1
fi
cd ../terraform/
terraform destroy