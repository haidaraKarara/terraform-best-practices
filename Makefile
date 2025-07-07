.PHONY: help init upgrade validate plan apply destroy fmt docs clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init     - Initialize Terraform"
	@echo "  upgrade  - Upgrade provider versions (use with caution)"
	@echo "  validate - Validate Terraform files"
	@echo "  plan     - Create execution plan"
	@echo "  apply    - Apply changes"
	@echo "  destroy  - Destroy infrastructure"
	@echo "  fmt      - Format Terraform files"
	@echo "  docs     - Generate documentation"
	@echo "  clean    - Clean temporary files"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Upgrade provider versions (use with caution)
upgrade:
	@echo "⚠️  Upgrading provider versions - this may break existing configurations!"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	terraform init -upgrade

# Validate Terraform configuration
validate: fmt
	@echo "Validating Terraform configuration..."
	terraform validate

# Create execution plan
plan: validate
	@echo "Creating execution plan..."
	terraform plan -out=tfplan

# Apply changes
apply: plan
	@echo "Applying changes..."
	terraform apply tfplan

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure..."
	terraform destroy -auto-approve

# Format Terraform files
fmt: init
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Generate documentation (requires terraform-docs)
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README.md --output-mode inject .; \
	else \
		echo "terraform-docs not found. Install it with: brew install terraform-docs"; \
	fi

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -f tfplan
	rm -f terraform.tfstate.backup
	rm -f .terraform.lock.hcl
	rm -rf .terraform/