                                         Automated CI/CD Pipeline & IaC Provisioning

This repository contains a fully automated Continuous Integration and Continuous Deployment (CI/CD) pipeline. It demonstrates the zero-touch deployment of a containerized application to AWS infrastructure, provisioned entirely via Infrastructure as Code (IaC).

🚀 Project Overview

The objective of this project is to showcase modern DevOps engineering practices. By pushing code to the `main` branch, a GitHub Actions workflow is triggered that automatically:
1. Builds a Docker image containing an NGINX web server and a static HTML payload.
2. Authenticates and pushes the compiled image to a Docker Hub registry.
3. Retrieves the current infrastructure state from a secure AWS S3 backend.
4. Provisions an Amazon EC2 instance and configures networking security groups using Terraform.
5. Executes a `cloud-init` script to automatically install Docker, pull the latest image, and deploy the container on the newly created server upon boot.

🛠️ Technologies & Tools
* Continuous Integration:** GitHub Actions
* Containerization:** Docker, Docker Hub
* Infrastructure as Code (IaC): Terraform
* Cloud Provider:** Amazon Web Services (AWS EC2)
* State Management: AWS S3
* Web Server: NGINX
* Automation Scripts:** Bash (`cloud-init` / `user_data`)

🏗️ Pipeline Architecture

1. Source Control:** Developer pushes code to the repository.
2. CI Phase (Build & Push):
   * GitHub Actions provisions a clean Ubuntu runner.
   * Securely authenticates with Docker Hub using encrypted GitHub Secrets.
   * Builds the NGINX `Dockerfile` and pushes the `latest` tag to the container registry.
3. CD Phase (Provision & Deploy):
   * GitHub Actions assumes AWS IAM credentials and initializes the AWS S3 Remote Backend to load the existing environment state.
   * Terraform executes a teardown of the old environment and strictly applies the new configuration, requesting a new `t3.micro` EC2 instance and opening ports 80 (HTTP) and 22 (SSH).
   * A bash bootstrapping script runs on instance startup to configure the host environment, pull the new container, and expose the application to the public web.
  
By storing the state remotely in a private AWS S3 Bucket, this pipeline achieves:
* Idempotency: Terraform accurately compares the desired code against the real-world AWS environment, ensuring it seamlessly destroys, creates, or updates only what is absolutely necessary without naming collisions.
* Security: State files often map sensitive infrastructure details. Storing them in a locked S3 bucket guarantees zero data leakage into the public GitHub codebase.
* Enterprise Readiness:** Remote state is a mandatory practice for DevOps teams, preventing multiple engineers from accidentally overwriting each other's infrastructure changes concurrently.

📂 Repository Structure

* `.github/workflows/deploy.yml`: The GitHub Actions CI/CD workflow definition.
* `main.tf`: Terraform configuration file for AWS resource provisioning and security group rules.
* `Dockerfile`: Container blueprint utilizing the official lightweight `nginx:alpine` image.
* `index.html`: The static web payload served by NGINX.

💡 Key DevOps Principles Demonstrated

* Immutable Infrastructure:** Server environments are completely reproducible and configured through code, avoiding configuration drift.
* Remote State Management: Utilizing S3 to maintain a single secure source of truth for infrastructure.
* Separation of Concerns: Application logic (HTML/NGINX), packaging (Docker), and delivery (GitHub Actions/Terraform) are decoupled.
* Secrets Management: AWS API keys and Docker Hub credentials are systematically injected via secure environment variables, ensuring zero credential leakage in the public codebase.
* Zero-Touch Deployment: The entire release cycle requires zero manual intervention post-commit.


🚀 How to Use This Pipeline for Your Own App

Because this deployment pipeline is fully containerized, you can easily swap out the static site payload and use this exact infrastructure to deploy your own application (e.g., Node.js, Python Flask, React) to AWS.

1. Fork and Clone
Fork this repository to your own GitHub account and clone it to your local workspace.

2. Configure Your Secrets
In your new GitHub repository, navigate to **Settings > Secrets and variables > Actions** and add your own credentials:
* `AWS_ACCESS_KEY_ID`: Your AWS IAM programmatic access key.
* `AWS_SECRET_ACCESS_KEY`: Your AWS IAM secret access key.
* `DOCKERHUB_USERNAME`: Your Docker Hub username.
* `DOCKERHUB_TOKEN`: Your Docker Hub personal access token.

3. Configure the S3 Backend
* Create a private S3 bucket in your AWS account to hold the state file.
* Open `main.tf` and update the `backend "s3"` block with your specific bucket name.

4. Swap the Application Payload
Delete the `index.html` file and drop in your own application's source code.
Update the `Dockerfile` to build your specific tech stack instead of NGINX (e.g., `FROM node:18`, `FROM python:3.10`).

5. Adjust the Ports (If Necessary)
By default, this infrastructure is configured for standard web traffic on port `80`. If your custom app runs on a different port (like `3000` or `5000`), make these two quick changes in `main.tf`:
* Security Group: Update the `aws_security_group` ingress rule from `80` to your app's port so the AWS firewall allows the traffic.
* Docker Run: Update the `user_data` boot script to map your port (e.g., `docker run -p 80:3000`).

5. Push to Deploy
Commit your updated application and push it to your `main` branch. GitHub Actions will automatically read your new Dockerfile, push the image to your Docker Hub registry, and command Terraform to provision a new EC2 instance running your app.
