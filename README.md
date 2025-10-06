# S3 Static Website with IP Restrictions

This Terraform configuration creates an S3 bucket configured for static website hosting with private access and IP-based restrictions.

## ⚠️ Important Limitation

**This configuration has a fundamental limitation**: S3 static website hosting with IP-based restrictions using bucket policies is **not possible** when `block_public_policy = true`.

The S3 static website hosting feature requires some level of public access to function, and the security settings conflict with IP restriction approaches using bucket policies.

## Features

- ✅ S3 Static Website Hosting enabled
- ✅ Private access (blocks all public access)
- ❌ IP-based access control (not possible with current approach)
- ✅ Custom index and error pages
- ✅ Random bucket name to avoid conflicts

## Alternative Solutions

Since IP restrictions with bucket policies are not possible, consider these alternatives:

1. **CloudFront + WAF**: Use CloudFront distribution with AWS WAF for IP-based access control
2. **Application Load Balancer**: Use ALB with security groups for IP filtering
3. **API Gateway**: Use API Gateway with Lambda authorizers
4. **VPN/Private Network**: Keep bucket private and access through VPN
5. **Basic Auth**: Implement client-side authentication (less secure)

## Configuration

### Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed
3. Valid AWS account with S3 permissions

### Setup

1. **Deploy the infrastructure**:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. **Access the website**:
   After deployment, Terraform will output the website URL. The website will be publicly accessible.

## Important Notes

- **Public Access**: The website will be publicly accessible (no IP restrictions possible)
- **Private Access**: The bucket blocks all public access by default
- **Bucket Name**: Uses a random suffix to ensure uniqueness
- **Region**: Currently configured for `ap-southeast-2` (Sydney)

## Customization

- **Change Region**: Update the `region` in the `provider` block
- **Modify Content**: Edit `index.html` and `error.html` files
- **Change Bucket Name**: Modify the bucket name in the `aws_s3_bucket` resource

## Security

This configuration implements:

- Public access blocking (but website remains accessible)
- Private bucket policy
- Secure content delivery

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Troubleshooting

- **Access Denied**: This is expected - the website is publicly accessible
- **Website Not Loading**: Check that the bucket policy is correctly configured
- **Terraform Errors**: Verify AWS credentials and permissions
