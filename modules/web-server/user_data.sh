#!/bin/bash
# Custom user data script for EC2 instance to configure S3 access

# Update system
yum update -y

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install useful tools
yum install -y htop tree wget curl

# Install and configure AWS Systems Manager Agent
echo "$(date): Installing and configuring SSM Agent..." >> /var/log/user-data.log
yum install -y amazon-ssm-agent

# Enable SSM Agent to start at boot
systemctl enable amazon-ssm-agent

# Start SSM Agent immediately
systemctl start amazon-ssm-agent

# Verify SSM Agent status and log it
echo "$(date): Checking SSM Agent status..." >> /var/log/user-data.log
systemctl status amazon-ssm-agent >> /var/log/user-data.log 2>&1

# Wait for SSM Agent to be fully ready
sleep 30

# Verify SSM registration
echo "$(date): Verifying SSM Agent registration..." >> /var/log/user-data.log
if systemctl is-active --quiet amazon-ssm-agent; then
    echo "$(date): ✅ SSM Agent is running and ready for Session Manager" >> /var/log/user-data.log
else
    echo "$(date): ❌ SSM Agent failed to start properly" >> /var/log/user-data.log
fi

# Create a test script for S3 operations
cat > /home/ec2-user/s3-test.sh << 'EOF'
#!/bin/bash
# Test script for S3 operations

S3_BUCKET="${s3_bucket_name}"
TEST_FILE="/tmp/test-file.txt"

echo "Testing S3 operations with bucket: $S3_BUCKET"

# Create a test file
echo "Hello from EC2 instance $(hostname) at $(date)" > $TEST_FILE

# Upload file to S3
echo "Uploading file to S3..."
aws s3 cp $TEST_FILE s3://$S3_BUCKET/test-files/

# List objects in S3
echo "Listing objects in S3 bucket..."
aws s3 ls s3://$S3_BUCKET/test-files/

# Download file from S3
echo "Downloading file from S3..."
aws s3 cp s3://$S3_BUCKET/test-files/test-file.txt /tmp/downloaded-file.txt

# Compare files
echo "Comparing original and downloaded files..."
diff $TEST_FILE /tmp/downloaded-file.txt

if [ $? -eq 0 ]; then
    echo "✅ S3 operations test PASSED!"
else
    echo "❌ S3 operations test FAILED!"
fi

# Clean up
rm -f $TEST_FILE /tmp/downloaded-file.txt
EOF

# Make script executable
chmod +x /home/ec2-user/s3-test.sh
chown ec2-user:ec2-user /home/ec2-user/s3-test.sh

# Create a welcome message
cat > /etc/motd << 'EOF'
====================================
 Welcome to your EC2 Web Server!
====================================

This instance has been configured with:
- AWS CLI v2
- IAM role for S3 access
- S3 test script at ~/s3-test.sh

To test S3 connectivity, run:
  ./s3-test.sh

Enjoy your infrastructure!
====================================
EOF

echo "User data script completed successfully" >> /var/log/user-data.log