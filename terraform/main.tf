provider "aws" {
    region     = var.aws_region
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
}

module "myapp-vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.1"

    name = "myapp-vpc"
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks
    azs = data.aws_availability_zones.available.names 
    
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true

    tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    }

    public_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1 
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1 
    }

}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name = var.k8s_cluster_name
  cluster_version = var.k8s_version

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  # to access cluster externally with kubectl
  cluster_endpoint_public_access = true 

  node_security_group_additional_rules = {
    # source_cluster_security_group = true
                                                                  
    rule2 = {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    rule3 = {
      from_port   = 8300
      to_port     = 8300
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    rule4 = {
      from_port   = 8301
      to_port     = 8301
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    rule5 = {
      from_port   = 8500
      to_port     = 8500
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    rule6 = {
      from_port   = 8600
      to_port     = 8600
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    rule7 = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    rule8 = {
      from_port   = 8558
      to_port     = 8558
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    rule9 = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]

      # add permission for ebs storage creation for Consul
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      } 
    }
  }
}

# enable ebs-csi driver add-on for ebs storage creation for Consul
resource "aws_eks_addon" "ebs" {
  cluster_name      = module.eks.cluster_name
  addon_name        = "aws-ebs-csi-driver"
}