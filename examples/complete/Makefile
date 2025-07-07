.PHONY: help init upgrade validate plan apply destroy fmt clean test

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
	@echo "  clean    - Clean temporary files"
	@echo "  test     - Test S3 connectivity (requires infrastructure to be deployed)"

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
	@echo ""
	@echo "🎉 Infrastructure deployed successfully!"
	@echo "📋 Next steps:"
	@echo "   1. SSH into the instance: $$(terraform output -raw ssh_command)"
	@echo "   2. Test S3 connectivity: ./s3-test.sh"

# Destroy infrastructure
destroy:
	@echo "⚠️  This will destroy all infrastructure!"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	terraform destroy

# Format Terraform files
fmt: init
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -f tfplan
	rm -f terraform.tfstate.backup
	rm -f .terraform.lock.hcl
	rm -rf .terraform/

# Test S3 connectivity (requires infrastructure to be deployed)
test:
	@echo "Testing S3 connectivity..."
	@INSTANCE_IP=$$(terraform output -raw ec2_public_ip 2>/dev/null || echo ""); \
	if [ -z "$$INSTANCE_IP" ]; then \
		echo "❌ No EC2 instance found. Run 'make apply' first."; \
		exit 1; \
	fi; \
	echo "📍 Instance IP: $$INSTANCE_IP"; \
	echo "🔗 SSH command: $$(terraform output -raw ssh_command)"; \
	echo "🧪 Run './s3-test.sh' after SSH-ing into the instance"