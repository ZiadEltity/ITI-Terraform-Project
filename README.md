# ITI-Terraform-Project

![terraa](https://github.com/user-attachments/assets/44494013-6ff5-4b6a-8ae2-db496c296ffc)


## Project Description

This project aims to set up a (CI/CD) pipeline using Jenkins, Ansible, and GitLab. It involves provisioning virtual machines (VMs) with dedicated services, managing user access, integrating GitLab with Jenkins, and detecting a code commit to make the Jenkins pipeline autonomously execute an ansible playbook to install and configure Apache HTTP Server and generate an email notification if the pipeline fails.

## Instructions

1. **Work on "dev" workspace.**
2. **Terraform modules.**
3. **Remote bucket for statefile.**
4. **DynamoDB State Locking**
5. **Remote provisioner to install apache or proxy in the machines.**
6. **Local-exec provisioner to print all the machines ip to a file "all-ips.txt".**
7. **Remote-exec provisioner to transfer "index.html" to the private ec2s.**
8. **Datasource to get the image id for ec2.**


## Setup
