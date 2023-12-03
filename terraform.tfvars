aws_region            = "ap-south-1"
env                   = "RM"
hostname_prefix       = "INMUZA"
vpc_cidr              = "10.71.32.0/20"
vpc_type              = "LAN"
type                  = "APP"
product               = "ESG"
fw_gateway_ip_address = ["44.197.58.234", "54.158.140.229"]
bgp_asn               = "65000"

subnet_cidr_web = {
  "10.71.32.0/24" = "ap-south-1a"
  "10.71.33.0/24" = "ap-south-1b"
  "10.71.34.0/24" = "ap-south-1c"
}
subnet_cidr_APP = {
  "10.71.35.0/24" = "ap-south-1a"
  "10.71.36.0/24" = "ap-south-1b"
  "10.71.37.0/24" = "ap-south-1c"
}
subnet_cidr_DB = {
  "10.71.38.0/24" = "ap-south-1a"
  "10.71.39.0/24" = "ap-south-1b"
  "10.71.40.0/24" = "ap-south-1c"
}

transit_gateway_id = "tgw-0bf95b3106bfdfb85"
share_account_id   = "149025769451"
inbound_ports_LAN = [
  {
    port        = 443,
    protocol    = "tcp"
    cidr_blocks = ["10.95.5.148/32"]
    description = "https access"
  }
]
inbound_ports_web = [
  {
    port        = 443,
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "https access"
  },
  {
    port        = 80,
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "http access"
  },
]

inbound_ports_infra = [
  {
    port        = 22,
    protocol    = "tcp"
    cidr_blocks = ["10.95.5.10/32", "192.168.250.131/32", "10.95.5.148/32", "192.168.11.102/32"]
    description = "SSH Access"
  },
  {
    port        = 0,
    protocol    = -1
    cidr_blocks = ["10.95.5.103/32", "10.95.5.223/32"]
    description = "ZPA connector"
  },
  {
    port        = 0,
    protocol    = -1
    cidr_blocks = ["10.95.5.143/32", "10.95.5.136/32"]
    description = "Cyberark connector"
  }
]