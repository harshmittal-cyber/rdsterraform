resource "aws_vpc" "harsh_aurora_vpc" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}

resource "aws_subnet" "harsh_aurora_subnet_1" {
  vpc_id                  = aws_vpc.harsh_aurora_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-1a"  # Replace with your desired availability zone
}

resource "aws_subnet" "harsh_aurora_subnet_2" {
  vpc_id                  = aws_vpc.harsh_aurora_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1b"  # Replace with your desired availability zone
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "aurora-subnet-group"
  description = "Aurora subnet group"
  subnet_ids  = [aws_subnet.harsh_aurora_subnet_1.id, aws_subnet.harsh_aurora_subnet_2.id]
    tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}

resource "aws_security_group" "aurora_security_group" {
  name        = "aurora-security-group"
  description = "Security group for Aurora"

  vpc_id = aws_vpc.harsh_aurora_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}

resource "aws_db_instance" "harsh_db_instance" {
  identifier = "my-sql-harsh"
  allocated_storage    = 10
  max_allocated_storage = 20
  db_name              = "aws_ceq_poc_harsh"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "harsh"
  password             = "harshmittal"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name  = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_security_group.id]
  multi_az    = true # Custom for Oracle does not support multi-az
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}

#maria db
resource "aws_db_instance" "harsh1_db_instance" {
  identifier             = "maria-db-instance-harsh"
  engine                 = "mariadb"
  engine_version         = "10.6.10"
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  max_allocated_storage = 30
  storage_type           = "gp2"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_security_group.id]
  db_name = "awsceqpocdb"
  username               = "harsh1"
  password               = "harshmittal1"
  parameter_group_name = "default.mariadb10.6"
  multi_az = true
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
  skip_final_snapshot  = true
}