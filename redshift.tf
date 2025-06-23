# Creating VPC for Redshift
resource "aws_vpc" "redshift_vpc" {
  cidr_block = "10.1.0.0/16"
}

# Creating my first public subnet in the VPC
resource "aws_subnet" "rs_public_subnet_1" {
  cidr_block        = "10.1.1.0/24"
  availability_zone = "eu-west-1a"
  vpc_id            = aws_vpc.redshift_vpc.id

  tags = {
    Name    = "rs_public_subnet_1"
    service = "Redshift"
  }
}

# Creating my second public subnet in the VPC
resource "aws_subnet" "rs_public_subnet_2" {
  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-west-1b"
  vpc_id            = aws_vpc.redshift_vpc.id

  tags = {
    Name    = "rs_public_subnet_2"
    service = "Redshift"
  }
}

# Created an Internet Gateway for the VPC
resource "aws_internet_gateway" "redshift_igw" {
  vpc_id = aws_vpc.redshift_vpc.id

  tags = {
    Name = "redshift_igw"
  }
}

# Created a route table for the VPC
resource "aws_route_table" "redshift_rt" {
  vpc_id = aws_vpc.redshift_vpc.id

  tags = {
    Name = "redshift_rt"
  }
}

# Adding route to the route table to allow internet access
resource "aws_route" "redshift_route" {
  route_table_id         = aws_route_table.redshift_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.redshift_igw.id
}

# Linking the first public subnet with the route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.rs_public_subnet_1.id
  route_table_id = aws_route_table.redshift_rt.id
}

# Linking the second public subnet with the route table
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.rs_public_subnet_2.id
  route_table_id = aws_route_table.redshift_rt.id
}

# Created a Redshift subnet group
resource "aws_redshift_subnet_group" "rs_subnet_group" {
  name       = "rs_subnet_group"
  subnet_ids = [
    aws_subnet.rs_public_subnet_1.id,
    aws_subnet.rs_public_subnet_2.id
  ]

  tags = {
    environment = "development"
    service     = "Redshift"
  }
}

# Creating an IAM role for the Redshift cluster
resource "aws_iam_role" "redshift_role" {
  name = "redshift_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "redshift-role"
  }
}

# Create a policy for the Redshift IAM role
resource "aws_iam_role_policy" "redshift_policy" {
  name = "redshift_policy"
  role = aws_iam_role.redshift_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      }
    ]
  })
}

# Generating a random password for the Redshift database
resource "random_password" "password" {
  length  = 12
  special = false
}

# Stores the Redshift database password in SSM
resource "aws_ssm_parameter" "redshift_db_password" {
  name  = "redshift_db_password"
  type  = "SecureString"
  value = random_password.password.result
}

# Create a security group for the Redshift cluster
resource "aws_security_group" "redshift_sg" {
  name        = "allow_redshift_traffic"
  description = "Allow inbound and outbound traffic for Redshift"
  vpc_id      = aws_vpc.redshift_vpc.id

  tags = {
    Name = "redshift_sg"
  }
}

# Creating ingress rule to allow traffic on port 5439 (Redshift default port)
resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.redshift_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5439
  to_port           = 5439
  ip_protocol       = "tcp"
}

# Create an egress rule to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.redshift_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create the Redshift cluster
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier  = "redshift-cluster"
  database_name       = "DE_DB"
  master_username     = "kaycee"
  master_password     = aws_ssm_parameter.redshift_db_password.value
  node_type           = "dc2.large"
  cluster_type        = "multi-node"
  number_of_nodes     = 3
  iam_roles           = [aws_iam_role.redshift_role.arn]
  publicly_accessible = true
  cluster_subnet_group_name = aws_redshift_subnet_group.rs_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.redshift_sg.id]

  depends_on = [
    aws_redshift_subnet_group.rs_subnet_group,
    aws_security_group.redshift_sg
  ]
}
