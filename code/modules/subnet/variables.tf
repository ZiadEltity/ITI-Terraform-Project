variable "myvpc_id" {}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    "pubSub1" = {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "us-east-1a"
    }
    "pubSub2" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
}


variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    "privSub1" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    "privSub2" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "us-east-1b"
    }
  }
}



