# eks.tf - Definición del Clúster de Kubernetes

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "tfg-cluster"
  cluster_version = "1.30" # Versión estable de Kubernetes (sin ser la más actual)

  # Conectamos el clúster a la VPC que creamos en vpc.tf
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Habilitado acceso público a la API para controlarlo desde la terminal local
  cluster_endpoint_public_access  = true

  # Dando permisos al usuario de la web ---
  access_entries = {
    usuario_web_root = {
      principal_arn = "arn:aws:iam::951343842744:root" # El ARN exacto que te da el error
      
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Permisos de administrador al usuario que está creando el clúster 
  enable_cluster_creator_admin_permissions = true

  # Instalamos el driver (traductor) de discos EBS ---
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Definición de las máquinas virtuales (Worker Nodes)
  eks_managed_node_groups = {
    nodos_tfg = {
      min_size     = 1
      max_size     = 5
      desired_size = 3 

      instance_types = ["t3.small"] 
      ami_type       = "AL2_x86_64" # <-- Especificamos explícitamente el sistema operativo base

      # --- NUEVO: Le damos permiso a las máquinas para crear discos ---
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      # ----------------------------------------------------------------
    }
  }
}
