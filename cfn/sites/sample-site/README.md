# Sample React Website

A React + TypeScript static website template for AWS deployment using S3 and CloudFront.

## Project Structure

```
sample-site/
├── src/                    # React source code
├── public/                 # Static assets
├── dist/                   # Build output (generated)
├── template.yaml           # CloudFormation template
├── deploy.sh              # Deployment script
├── package.json           # Node.js dependencies
└── README.md              # This file
```

## Prerequisites

- Node.js (v18 or later)
- AWS CLI configured with appropriate permissions
- AWS account with CloudFormation, S3, and CloudFront access

## Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server:
   ```bash
   npm run dev
   ```

3. Build for production:
   ```bash
   npm run build
   ```

## AWS Deployment

1. Make sure AWS CLI is configured:
   ```bash
   aws configure
   ```

2. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

The deployment script will:
- Build the React application
- Deploy CloudFormation template
- Upload files to S3
- Create CloudFront invalidation
- Display website URLs

## AWS Resources

The CloudFormation template creates:
- **S3 Bucket**: Static website hosting
- **S3 Bucket Policy**: Public read access
- **CloudFront Distribution**: CDN with HTTPS

## Configuration

Edit `deploy.sh` to customize:
- `STACK_NAME`: CloudFormation stack name
- `BUCKET_PREFIX`: S3 bucket name prefix
- `REGION`: AWS region

## Cleanup

To remove all AWS resources:
```bash
aws cloudformation delete-stack --stack-name sample-site-stack
```
