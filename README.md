# ITI-Terraform-Project

![terraa](https://github.com/user-attachments/assets/44494013-6ff5-4b6a-8ae2-db496c296ffc)


## Project Description

This Terraform setup provisions a highly available web application infrastructure within AWS, using EC2 instances distributed across multiple availability zones. Using NLB in front of the NGINX proxy servers to distribute incoming traffic evenly across both public subnets,and ALB in front of the APACHE web servers for distributing traffic to the private web servers . 


## Applied Concepts

1. **Work on "dev" workspace.**
2. **Terraform Modules.**
3. **Remote bucket for statefile.**
4. **DynamoDB State Locking.**
5. **Datasource to get the image id for ec2.**
6. **for_each and dynamic Blocks**
7. **Remote-exec provisioner to install apache or proxy in the machines.**
8. **Local-exec provisioner to print all the machines ip to a file "all-ips.txt".**
9. **File provisioner to transfer "index.html" to the private ec2s.**

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


## Remote bucket for statefile on "dev" workspace**

![Screenshot 2024-09-23 210241](https://github.com/user-attachments/assets/2c433ce3-8631-422f-a743-8ccf9722044d)


## DynamoDB State Locking

![Screenshot 2024-09-23 210346](https://github.com/user-attachments/assets/dace6b43-69c1-497f-9907-2a2a2c8e1b89)


## Terraform Modules

1. **Network Module:** To create VPC, IGW, Public RT, Private RT, NAT Gatway, Public SG, and Private SG.
2. **Subnet Module:** To create Public Subnets and Private Subnets.
3. **Instance Module:** To create EC2 instances in the public subnets that run NGINX and EC2 instances in the private subnets running Apache.
4. **Loadbalancer Module:** To create Network Load Balancer (NLB) and Application Load Balancer (ALB)

   
## Datasource to get the image id for ec2

```hc
data "aws_ami" "amz_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
```

## dynamic Blocks in SGs

```hc
resource "aws_security_group" "pub_sg" {
  vpc_id = aws_vpc.vpc1.id

  # Dynamic rule for SSH and HTTP based on the map variable
  dynamic "ingress" {
    for_each = var.security_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "pub_sg"
  }
}
```

## for-each in Subnets and EC2s

```hc
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = var.myvpc_id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = each.key
  }
}

```


## Remote-exec provisioner to install apache or proxy in the machines

```hc
  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      <<EOF
      echo 'server {
        listen 80;
        location / {
          proxy_pass http://${var.alb_private_dns};
        }
      }' | sudo tee /etc/nginx/conf.d/reverse-proxy.conf
      EOF
      ,"sudo systemctl restart nginx"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/ziad/Desktop/key.pem")
    host        = self.public_ip
  }
```


## Local-exec provisioner to print all the machines ip to a file "all-ips.txt"

```hc
  provisioner "local-exec" {
    command = "echo ${each.value.instance_name} Public IP ${self.public_ip} >> all-ips.txt"
  }

```


## File provisioner to transfer "index.html" to the private ec2s

```hc
  provisioner "file" {
    source      = each.value.file_source
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/ziad/Desktop/key.pem")
      host        = self.private_ip
      bastion_host = aws_instance.bast_host.public_ip
      bastion_user = "ec2-user"
      bastion_private_key = file("/home/ziad/Desktop/key.pem")
    }
  }
```

## Terraform Apply Result

![Picture1](https://github.com/user-attachments/assets/3d833a88-f620-44ea-b7cf-e267dcad2f35)


## Accessing the DNS

![Done2](https://github.com/user-attachments/assets/8ce9bb73-6ecb-43d0-8b4a-6a09f1e79cab)


## Terraform Destroy

![Screenshot 2024-09-23 042453](https://github.com/user-attachments/assets/cd8ab18d-aaa9-4fd2-a141-35778d09c2d1)

