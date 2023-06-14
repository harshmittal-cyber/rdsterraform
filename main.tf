resource "aws_vpc" "harsh_aurora_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
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

resource "aws_internet_gateway" "harshgateway" {
  vpc_id = aws_vpc.harsh_aurora_vpc.id
  
  tags = {
    Name="Harsh Mittal"
    Purpose= "template for vpc"
    Owner="harsh.mittal@cloudeq.com"
  }
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

# postgres sql default in ingress port
resource "aws_security_group" "harsh_postgres_security_group" {
  name        = "postgressql"
  description = "Security group for postgressql"
  vpc_id = aws_vpc.harsh_aurora_vpc.id

  # Specify your security group rules
  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_security_group" "harsh_oracle_sg" {
  name        = "oraclesecuritygroup"
  description = "oracle Security Group"
  vpc_id = aws_vpc.harsh_aurora_vpc.id

  ingress {
    from_port   = 1521  
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#mysql
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
  multi_az    = false
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
  multi_az = false
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
  skip_final_snapshot  = true
}

#postgressql
resource "aws_db_instance" "harsh2_postgres" {
  identifier = "postgres-babelfish-instance"
  engine = "postgres"
  instance_class = "db.t3.medium"
  db_name = "awsceq"
  allocated_storage  = 20
  publicly_accessible = true
  username = "harsh1"
  password = "harshmittal1"
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.harsh_postgres_security_group.id]
   tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
  skip_final_snapshot  = true  
}

# oracledb
resource "aws_db_instance" "harsh_oracle_db" {
  identifier = "oracle"
  engine = "oracle-se2"
  instance_class = "db.t3.medium"
  db_name = "awsceu"
  username = "harsh1"
  password = "harshmittal1"
  allocated_storage  = 20
  publicly_accessible = true
  db_subnet_group_name  = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.harsh_oracle_sg.id]

  license_model       = "license-included"
  backup_retention_period = 1
  # kms_key_id = "arnofkms"
  # storage_encrypted = true

  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
  skip_final_snapshot  = true 
}

# Create an RDS cluster with mysql engine
resource "aws_rds_cluster" "harsh_cluster" {
  cluster_identifier      = "harsh-cluster"
  engine                  = "aurora-mysql"
#   engine_version          = "5.7.mysql_aurora.2.11.2"
  master_username         = "harsh2"
  master_password         = "harshmittal23"
  backup_retention_period = 1
  preferred_backup_window = "02:00-03:00"
  #for encryption of storage make it true and specify kms_keyid
#   storage_encrypted  = true         
#   kms_key_id         = "harsh-kms-key" 
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_security_group.id]
  # availability_zones = ["ap-southeast-1a","ap-southeast-1b"] #for multiAZ
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}

# Create an RDS instance within the cluster with mysql
resource "aws_rds_cluster_instance" "harsh_cluster_instance" {
  identifier              = "harsh-cluster-instance"
  cluster_identifier      = aws_rds_cluster.harsh_cluster.id
  engine                  = "aurora-mysql"
  engine_version = aws_rds_cluster.harsh_cluster.engine_version_actual
  instance_class          = "db.t3.medium"
  availability_zone       = "ap-southeast-1a"
  publicly_accessible = false
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}


resource "aws_rds_cluster" "harsh_postgres_cluster" {
  cluster_identifier= "harsh1-cluster"
  engine   = "aurora-postgresql"
  engine_mode   = "provisioned"
  # engine_version   = "13.3"
  master_username         = "harsh2"
  master_password         = "harshmittal23"
  backup_retention_period       = 1
  preferred_backup_window       = "01:00-02:00"
  preferred_maintenance_window  = "sun:05:00-sun:06:00"

  # Other cluster configurations (e.g., instance type, storage, networking, etc.)
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_security_group.id]
  # availability_zones = ["ap-southeast-1a","ap-southeast-1b"]  #for multiAZ
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}

resource "aws_rds_cluster_instance" "postgres_instance" {
  cluster_identifier            = aws_rds_cluster.harsh_postgres_cluster.id
  engine                        = "aurora-postgresql"
  instance_class                = "db.t3.medium"
  publicly_accessible           = false
  engine_version = aws_rds_cluster.harsh_postgres_cluster.engine_version_actual
  availability_zone       = "ap-southeast-1a"
  tags={
    Name="Harsh Mittal"
    Owner="harsh.mittal@cloudeq.com"
    Purpose="POC"
  }
}