module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "ecommerce-cluster"
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  # ADD THIS for Jenkins connectivity
  cluster_endpoint_public_access = true 

  eks_managed_node_groups = {
    ecom_nodes = {
      ami_type = "AL2_x86_64"
      instance_types = ["c7i-flex.large"] 
      
      min_size     = 1
      max_size     = 3
      desired_size = 2 

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }

      capacity_type = "ON_DEMAND"
      
      labels = {
        role = "worker"
      }
    }
  }
}
