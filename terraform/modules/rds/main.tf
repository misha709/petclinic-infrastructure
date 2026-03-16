# ── Password ───────────────────────────────────────────────────────────────────
# Generated once and stored in Secrets Manager — never appears in plain state
# after the secret version is written.

resource "random_password" "db" {
  length           = 20
  special          = true
  override_special = "!#$%&*-_=+?"  # exclude chars that break connection-string parsing
}

# ── Secrets Manager ────────────────────────────────────────────────────────────
# Stores the full connection bundle so applications can call GetSecretValue
# and get everything they need in one API call.

resource "aws_secretsmanager_secret" "db" {
  name        = "${var.identifier}-db-credentials"
  description = "PostgreSQL credentials for the ${var.identifier} RDS instance"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  # Standard AWS RDS secret JSON schema — compatible with AWS SDK rotation lambdas.
  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
    password = random_password.db.result
  })
}

# ── Networking ─────────────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = "${var.identifier}-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Private subnets for the ${var.identifier} RDS instance"

  tags = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.identifier}-rds-sg"
  description = "Allow PostgreSQL traffic from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS cluster nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ── RDS Instance ───────────────────────────────────────────────────────────────
# Single instance, no Multi-AZ — appropriate for dev. Flip multi_az = true
# and set backup_retention_period >= 1 before promoting to production.

resource "aws_db_instance" "main" {
  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az                = false
  publicly_accessible     = false
  backup_retention_period = 0    # disable automated backups in dev to save cost
  skip_final_snapshot     = true # safe to destroy without a final snapshot in dev
  deletion_protection     = false

  tags = var.tags
}
