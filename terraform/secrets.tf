resource "random_password" "database" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = 1
  }
}

resource "aws_secretsmanager_secret" "default" {
  name = local.name
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = <<EOF
  {
    "DATABASE_NAME": "${var.database_name}",
    "DATABASE_USER": "${var.database_user}",
    "DATABASE_PASS": "${random_password.database.result}",
    "DATABASE_HOST": "${aws_db_instance.default.address}",
    "DATABASE_PORT": "${aws_db_instance.default.port}"
  }
EOF
}