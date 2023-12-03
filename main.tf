
# Provider configuration
provider "aws" {
  region     = var.aws_region
  access_key = "sdaas"
  secret_key = "U+dasda"

}

provider "aws" {
  region     = var.aws_region
  access_key = "dadasdad"
  secret_key = "dasda"
  alias      = "ESG"

}

terraform {
  backend "s3" {
    bucket         = "network-terraform-state-store"
    key            = "INFRA/NETWORK/ESG-RM.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
  }
}

# VPC module
module "vpc" {
  source          = "./iac-itsec-foundational-modules/Network/vpc/"
  hostname_prefix = var.hostname_prefix
  env             = var.env
  product         = var.product
  vpc_cidr        = var.vpc_cidr
  vpc_type        = "LAN"
}

module "subnet" {
  source          = "./iac-itsec-foundational-modules/Network/subnet"
  vpc_id          = module.vpc.vpc_id
  subnet_cidr     = var.subnet_cidr_APP
  route_table_id  = module.route_table.route_table
  hostname_prefix = var.hostname_prefix
  env             = var.env
  product         = var.product
  type            = var.type
}

module "subnet_DB" {
  source          = "./iac-itsec-foundational-modules/Network/subnet"
  vpc_id          = module.vpc.vpc_id
  subnet_cidr     = var.subnet_cidr_DB
  route_table_id  = module.route_table.route_table
  hostname_prefix = var.hostname_prefix
  env             = var.env
  product         = var.product
  type            = "DB"
}

module "subnet_ALB" {
  source          = "./iac-itsec-foundational-modules/Network/subnet"
  vpc_id          = module.vpc.vpc_id
  subnet_cidr     = var.subnet_cidr_web
  route_table_id  = module.route_table_ALB.route_table
  hostname_prefix = var.hostname_prefix
  env             = var.env
  product         = var.product
  type            = "WEB"
}



# route table module
module "route_table" {
  source          = "./iac-itsec-foundational-modules/Network/route_table"
  env             = var.env
  product         = var.product
  vpc_id          = module.vpc.vpc_id
  hostname_prefix = var.hostname_prefix
  vpc_type        = "LAN"
}

# route table module
module "route_table_ALB" {
  source          = "./iac-itsec-foundational-modules/Network/route_table"
  env             = var.env
  product         = var.product
  vpc_id          = module.vpc.vpc_id
  hostname_prefix = var.hostname_prefix
  vpc_type        = "WEB"
}

/***
module "Customer_gateway" {
  source = "./iac-itsec-foundational-modules/Network/Customer_gateway"
  cgw_bgp_asn = var.bgp_asn
  ip_address = var.fw_gateway_ip_address
  hostname_prefix = var.hostname_prefix
  env = var.env
  product = var.product

}

module "transite_gateway" {
source = "./iac-itsec-foundational-modules/Network/Transit_gateway/transite_gateway"
hostname_prefix = var.hostname_prefix

}

***/

# trait gateway attachement
module "Transit_gateway_association" {
  source             = "./iac-itsec-foundational-modules/Network/Transit_gateway/transite_gateway_association"
  product            = var.product
  #transit_gateway_id = module.transite_gateway.transit_gateway_id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  subnet_id          = [module.subnet.subnet_id, module.subnet_DB.subnet_id, module.subnet_ALB.subnet_id]
  env                = var.env
  hostname_prefix    = var.hostname_prefix
  vpc_type           = "LAN"
  #route = "10.72.0.0/21"
}


module "resource_share" {
  source           = "./iac-itsec-foundational-modules/Network/resource_share"
  hostname_prefix  = var.hostname_prefix
  env              = var.env
  product          = var.product
  share_account_id = var.share_account_id
}

module "aws_resource_association" {
  source         = "./iac-itsec-foundational-modules/Network/resource_share/aws_resource_association"
  share          = module.subnet.subnet_arn
  resource_share = module.resource_share.resource_share_id
}

module "aws_resource_association_db" {
  source         = "./iac-itsec-foundational-modules/Network/resource_share/aws_resource_association"
  share          = module.subnet_DB.subnet_arn
  resource_share = module.resource_share.resource_share_id
}
module "aws_resource_association_ALB" {
  source         = "./iac-itsec-foundational-modules/Network/resource_share/aws_resource_association"
  share          = module.subnet_ALB.subnet_arn
  resource_share = module.resource_share.resource_share_id
}


module "resource_share_tags" {
  source             = "./iac-itsec-foundational-modules/Network/resource_share/resource_share_tags"
  subnet_id          = module.subnet.subnet_id
  vpc_id             = module.vpc.vpc_id
  route_table_id_ALB = module.route_table_ALB.route_table
  route_table_id_LAN = module.route_table.route_table
  providers = {
    aws = aws.ESG
  }
  env             = var.env
  hostname_prefix = var.hostname_prefix
  product         = var.product
}

module "security_group_infra" {
  source          = "./iac-itsec-foundational-modules/Network/security_group"
  vpc_id          = module.vpc.vpc_id
  type            = "INFRA"
  inbound_ports   = var.inbound_ports_infra
  env             = var.env
  hostname_prefix = var.hostname_prefix
  product         = var.product
  providers = {
    aws = aws.ESG
  }

}

module "security_group_web" {
  source          = "./iac-itsec-foundational-modules/Network/security_group"
  vpc_id          = module.vpc.vpc_id
  type            = "WEB"
  inbound_ports   = var.inbound_ports_web
  env             = var.env
  hostname_prefix = var.hostname_prefix
  product         = var.product
  providers = {
    aws = aws.ESG
  }

}

module "security_group_lan" {
  source          = "./iac-itsec-foundational-modules/Network/security_group"
  vpc_id          = module.vpc.vpc_id
  type            = "LAN"
  inbound_ports   = var.inbound_ports_LAN
  env             = var.env
  hostname_prefix = var.hostname_prefix
  product         = var.product
  providers = {
    aws = aws.ESG
  }

}
