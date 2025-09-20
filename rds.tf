module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "mysql-db"

  engine               = "mysql"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"
  family               = "mysql8.0"
  allocated_storage    = 20

  db_name  = "task_app"
  username = var.db_username
  password = var.db_password
  port     = "3306"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  subnet_ids             = module.vpc.database_subnets

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.cluster_primary_security_group_id]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.1.101.0/24"]
  }

}
