# vpc.tf - Definición de la red para EKS

# Extraemos las Zonas de Disponibilidad (AZs) disponibles en tu región
data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "tfg-vpc"
  cidr = "10.0.0.0/16"

  # Usamos 2 Zonas de Disponibilidad (Requisito mínimo de EKS)
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Configuraciones críticas para que EKS y los contenedores tengan internet
  enable_nat_gateway   = true
  single_nat_gateway   = true 
  enable_dns_hostnames = true

  # Etiquetas obligatorias para que Kubernetes sepa dónde colocar los balanceadores de carga
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}