# 🚀 Terraform Setup for AWS Redshift Warehouse 🚀

Hi there! 👋  
This project helps you spin up an **Amazon Redshift cluster** using **Terraform**, with the right IAM permissions and clean configuration — perfect for analytics, data warehousing, or learning infrastructure-as-code.

## 🔧 What This Project Does

With just a few lines of code, this setup will:

- Create a Redshift cluster with your custom settings
- Attach the right IAM role with permissions
- Securely pull the master password from AWS Systems Manager Parameter Store (no hardcoding! ✅)

## 💡 What's Inside

- `providers.tf` –  this Sets up the AWS provider
- `redshift.tf` – This Handles the IAM role, policy, and Redshift cluster creation

## 🛠️ How to Use It

> Before you start, make sure:
> - Terraform is installed (`terraform -v`)
> - Your AWS credentials are configured
> - You’ve added a secret parameter in SSM (see below)


