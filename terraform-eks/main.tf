# main.tf - Configuración inicial y Proveedor
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Proyecto   = "TFG-ASIR"
      Entorno    = "Produccion"
      Gestionado = "Terraform"
    }
  }
}