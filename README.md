#  Terraform Setup for AWS Redshift Warehouse 

Hi there!  
This project helps you set up an **Amazon Redshift cluster** using **Terraform**, with  IAM permissions and clean configuration for data warehousing.
## 🔧 What This Project Does

 this setup usimg terraform will:

- Create a Redshift cluster with your customized settings
- Attach your IAM role with permissions
- Securely pull the master password from AWS Systems Manager Parameter Store.

##  What's Inside

- `providers.tf` –  this Sets up the AWS provider
- `redshift.tf` – This Handles the IAM role, policy, and Redshift cluster creation

## How to Use it.

> Before you start, make sure:
> - Terraform is installed (`terraform -v`)
> - Your AWS credentials are configured
> - Your secret parameter in SSM 

