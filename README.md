# ITI-Terraform-Project

![terraa](https://github.com/user-attachments/assets/44494013-6ff5-4b6a-8ae2-db496c296ffc)


## Project Description

This Terraform setup provisions a highly available web application infrastructure within AWS, using EC2 instances distributed across multiple availability zones. Using NLB in front of the NGINX proxy servers to distribute incoming traffic evenly across both public subnets,and ALB in front of the APACHE web servers for distributing traffic to the private web servers . 

## Concepts Applied

1. **Work on "dev" workspace.**
2. **Terraform modules.**
3. **Remote bucket for statefile.**
4. **DynamoDB State Locking.**
5. **Remote provisioner to install apache or proxy in the machines.**
6. **Local-exec provisioner to print all the machines ip to a file "all-ips.txt".**
7. **Remote-exec provisioner to transfer "index.html" to the private ec2s.**
8. **Datasource to get the image id for ec2.**


## VPC (Virtual Private Cloud)

![Screenshot 2024-09-23 033329](https://github.com/user-attachments/assets/022a3aff-dc16-4af8-b574-88a3e01d3e7c)

  - A VPC (10.0.0.0/16) is created to isolate the network resources for our application.
  - The VPC contains both public and private subnets across two availability zones (us-east-1a and us-east-1b) for high availability.


## Load Balancers

1. **Network Load Balancer (NLB)**:
   
![Screenshot 2024-09-23 033404](https://github.com/user-attachments/assets/cb1f414a-a12b-45dc-a76d-c973ebd9e4a9)

  - The NLB handles incoming traffic at the transport layer (TCP/UDP) and distributes it across the NGINX proxy servers in the public subnets. The NLB is optimized for handling high volumes of low-latency traffic.
  - Public access to the infrastructure starts through the NLB endpoint (http://public-nlb-***.amazonaws.com).

2. **Application Load Balancer (ALB)**:

![Screenshot 2024-09-23 033454](https://github.com/user-attachments/assets/8798e6cb-fc86-4921-b97a-c4bce7499fc8)

  - The ALB operates at the application layer (HTTP) and balances traffic between the NGINX proxies in the public subnets. It is configured for path-based routing, sticky sessions.
  - The ALB forwards traffic to the appropriate proxy server based on the application layer requests.


