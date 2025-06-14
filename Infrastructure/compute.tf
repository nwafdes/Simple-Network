# key
data "aws_key_pair" "s-kp" {
  key_name           = "bastion-host-key-pair"
  include_public_key = true

}

# Bastion host SG
resource "aws_security_group" "bastion-sg" {
  name        = "allow-ssh-bas"
  description = "Allow SSH inbound"
  vpc_id      = aws_vpc.s-p2.id

  tags = {
    Name = "allow_ssh-bas"
  }
}

# Bastion Host Ingress-SG-Rule
resource "aws_vpc_security_group_ingress_rule" "ingress-bastion-sg" {
  security_group_id = aws_security_group.bastion-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

# Bastion Host Egress-SG-Rule
resource "aws_vpc_security_group_egress_rule" "egress-bastion-sg" {
  security_group_id = aws_security_group.bastion-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"  # means all protocols
}


# sql server SG
resource "aws_security_group" "sql-sg" {
  name        = "allow-ssh-sql"
  description = "Allow SSH inbound"
  vpc_id      = aws_vpc.s-p2.id

  tags = {
    Name = "allow_ssh-sql"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress-sql-sg" {
  security_group_id = aws_security_group.sql-sg.id

  referenced_security_group_id = aws_security_group.bastion-sg.id # 
  ip_protocol = "tcp"
  from_port = 22
  to_port     = 22
}

# Bastion Host Egress-SG-Rule
resource "aws_vpc_security_group_egress_rule" "egress-sql-sg" {
  security_group_id = aws_security_group.sql-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"  # means all protocols
}

# Create an bastion Instance
resource "aws_instance" "bastion" {
  ami           = "ami-09e6f87a47903347c" # us-west-2
  instance_type = "t2.micro"  
  subnet_id = aws_subnet.s-pbs.id
  key_name = data.aws_key_pair.s-kp.key_name # 
  vpc_security_group_ids = [ aws_security_group.bastion-sg.id ] #

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "bastion-Host"
  }
}


resource "aws_instance" "sql" {
  ami           = "ami-09e6f87a47903347c" # us-west-2
  instance_type = "t2.micro"  
  subnet_id = aws_subnet.s-prs.id
  key_name = data.aws_key_pair.s-kp.key_name #
  vpc_security_group_ids = [ aws_security_group.sql-sg.id ] #

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "sql"
  }
}