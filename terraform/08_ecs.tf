resource "aws_ecs_cluster" "default" {
  name = local.name
}

resource "aws_launch_configuration" "default" {
  name                        = local.name
  image_id                    = lookup(var.amis, var.region)
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ecs.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = aws_key_pair.default.key_name
  associate_public_ip_address = true
  user_data                   = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER='${local.name}' > /etc/ecs/ecs.config
  EOF
}

resource "aws_ecs_task_definition" "default" {
  family                = local.name
  execution_role_arn       = aws_iam_role.task_definition.arn
  task_role_arn            = aws_iam_role.task_definition.arn
  container_definitions = jsonencode([
  {
    "name": "django",
    "image": "${replace("${aws_ecr_repository.django.repository_url}:latest", "https://", "")}",
    "essential": true,
    "cpu": 10,
    "memory": 512,
    "links": [],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "command": ["gunicorn", "-w", "3", "-b", ":80", "hello_django.wsgi:application"],
    "secrets": [
      for key, value in jsondecode(aws_secretsmanager_secret_version.default.secret_string): 
        {"name": key, "valueFrom": "${aws_secretsmanager_secret.default.arn}:${key}::"}
    ]
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.default.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "django"
      }
    }
  },])
}

resource "aws_ecs_service" "default" {
  name            = local.name
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  iam_role        = aws_iam_role.ecs_service.arn
  desired_count   = var.app_count
  depends_on      = [aws_iam_role_policy.ecs_service]

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "django"
    container_port   = 80
  }
}
