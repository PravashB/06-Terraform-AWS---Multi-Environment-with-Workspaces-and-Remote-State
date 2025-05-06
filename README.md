# 06-Terraform-AWS---Multi-Environment-with-Workspaces-and-Remote-State
In this lab, I'll walk you through How Large Organizations deploy infrastructure across environments safely..

![alt text](Pravash_Logo_Small.png)

## Objective
> In this lab, I'll show you How to:
    > - Use **Terraform Workspaces**** to manage multiple environments (dev, stage, prod).
    > - Separate **Terraform state files** per environment.
    > - Avoid conflicts and messy management.
    > - Follow real-world best practices for environment isolation.


## Before We move further, let's first refresh few basic Topics that are relevant to this Lab.
1. We know what is a **Terraform State** and **Remote State**

2. Why do we need **Multiple Environments?**
- > In real projects, we usually have **dev, stage & prod** environments.
- > Each environment should have it's own resources.
- > They should've their own **Terraform state** so that changes in DEV don't break PROD.

3. What are Workspaces?
- > Terraform workspaces lets us:
  > - Use the same **code**,
  > - But switch between **different environments** (like dev, state, prod),
  > - Each workspace has it's **own state file**

## Pre-requisites
- Completed 05-Terraform-AWS---Remote-State-Team-Collaboration-and-State-Locking lab.

- Remote backend (S3 + DynamoDB) already set up:

    - S3 bucket: terraform-bootstrap-pro-lab

    - DynamoDB table: terraform-lock-pro-lab

- Terraform Installed

- AWS CLI Configured

## Folder Structure
**In this lab, I'm going to use Single set of `.tf` files as I will use WORKSPACES to handle multiple environments dynamically.**

```
06-Terraform-AWS---Multi-Environment-with-Workspaces/
├── main.tf
├── provider.tf
├── variables.tf
├── backend.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```

## Step 1: Files to Create

```
touch main.tf provider.tf variables.tf backend.tf outputs.tf terraform.tfvars
```

**1. `provider.tf`**
```
provider "aws" {
    region = var.aws_region
}
```
**2. `variables.tf`**
```
variable "aws_region" {
    description = "AWS Region"
    type        = string
    default     = "us-east-1"
}
```

**3. `terraform.tfvars`** - We'll only set the AWS Region here. `environment` will be handled automatically from the workspace name. I'll show you how!

```
aws_region = "us-east-1"
```

**4. `backend.tf`**
```
terraform {
  backend "s3" {
    bucket         = "terraform-bootstrap-pro-lab"
    key            = "projects/sample-app/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-pro-lab"
    encrypt        = true
  }
}
```
**WHAT & WHY?**
- `${terraform.workspace}` is automatically injected. Terraform automatically replaces this with the current workspace name (like dev, stage, prod).
- So, dev/stage/prod will have **separate state files** like:
    - `projects/sample-app/dev/terraform.tfstate`
    - `projects/sample-app/stage/terraform.tfstate`
    - `projects/sample-app/prod/terraform.tfstate`

**5. `main.tf`**
I'll create different S3 buckets for each environement. And the bucket names will be different for each workspace to avoid collisions.

```
resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

resource "aws_s3_bucket" "env_bucket" {
  bucket = "sample-app-${terraform.workspace}-pro-${random_integer.suffix.result}"

  tags = {
    Name        = "SampleApp-${terraform.workspace}-Bucket"
    Environment = terraform.workspace
  }
}
```

**6. `outputs.tf`**
```
output "environment_bucket_name" {
  description = "The name of the environment-specific S3 bucket"
  value       = aws_s3_bucket.env_bucket.id
}
```
