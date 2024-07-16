resource "aws_ecs_cluster" "default" {
  name = local.name
}

# resource "aws_launch_configuration" "default" {
#   name                        = local.name
#   image_id                    = lookup(var.amis, var.region)
#   instance_type               = var.instance_type
#   security_groups             = [aws_security_group.ecs.id]
#   iam_instance_profile        = aws_iam_instance_profile.ecs.name
#   key_name                    = aws_key_pair.default.key_name
#   associate_public_ip_address = true
#   user_data                   = <<EOF
#     #!/bin/bash
#     echo ECS_CLUSTER='${local.name}' > /etc/ecs/ecs.config
#   EOF
# }

resource "aws_ecs_task_definition" "default" {
  family                = local.name
  execution_role_arn       = aws_iam_role.task_definition.arn
  task_role_arn            = aws_iam_role.task_definition.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
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
        "hostPort": 80,
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
  depends_on = [aws_ecs_task_definition.default]
  launch_type                        = "FARGATE"
  name            = local.name
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  platform_version                   = "LATEST"
  # iam_role        = aws_iam_role.ecs_service.arn
  desired_count   = var.app_count
  # depends_on      = [aws_iam_role_policy.ecs_service]

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  force_new_deployment               = true

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups    = [aws_security_group.load_balancer.id]
    subnets            = local.public_subnets_ids
  }

  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = "django"
    container_port   = 80
  }
}
