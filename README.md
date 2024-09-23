# ITI-Terraform-Project

![terraa](https://github.com/user-attachments/assets/44494013-6ff5-4b6a-8ae2-db496c296ffc)


## Project Description

This Terraform setup provisions a highly available web application infrastructure within AWS, using EC2 instances distributed across multiple availability zones. Using NLB in front of the NGINX proxy servers to distribute incoming traffic evenly across both public subnets,and ALB in front of the APACHE web servers for distributing traffic to the private web servers . 


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


## Concepts Applied

1. **Work on "dev" workspace**

![Picture1](https://github.com/user-attachments/assets/36082f28-7b90-42c0-a70c-9684e462b04c)

2. **Terraform modules.**

module "network" {
  source       = "./modules/network"
  pub_sub1_id  = module.subnet.pub_sub1_id
  pub_sub2_id  = module.subnet.pub_sub2_id
  priv_sub1_id = module.subnet.priv_sub1_id
  priv_sub2_id = module.subnet.priv_sub2_id
}

module "subnet" {
  source   = "./modules/subnet"
  myvpc_id = module.network.myvpc_id
}

module "instance" {
  source          = "./modules/instance"
  pub_sg_id       = module.network.pub_sg_id
  priv_sg_id      = module.network.priv_sg_id
  pub_sub1_id     = module.subnet.pub_sub1_id
  pub_sub2_id     = module.subnet.pub_sub2_id
  priv_sub1_id    = module.subnet.priv_sub1_id
  priv_sub2_id    = module.subnet.priv_sub2_id
  alb_private_dns = module.loadbalancer.alb_private_dns
}


module "loadbalancer" {
  source       = "./modules/loadbalancer"
  myvpc_id     = module.network.myvpc_id
  pub_sg_id    = module.network.pub_sg_id
  priv_sg_id   = module.network.priv_sg_id
  pub_sub1_id  = module.subnet.pub_sub1_id
  pub_sub2_id  = module.subnet.pub_sub2_id
  priv_sub1_id = module.subnet.priv_sub1_id
  priv_sub2_id = module.subnet.priv_sub2_id
  nginx1_id    = module.instance.nginx1_id
  nginx2_id    = module.instance.nginx2_id
  web1_id      = module.instance.web1_id
  web2_id      = module.instance.web2_id
}

3. **Remote bucket for statefile.**
4. **DynamoDB State Locking.**
5. **Remote provisioner to install apache or proxy in the machines.**
6. **Local-exec provisioner to print all the machines ip to a file "all-ips.txt".**
7. **Remote-exec provisioner to transfer "index.html" to the private ec2s.**
8. **Datasource to get the image id for ec2.**
