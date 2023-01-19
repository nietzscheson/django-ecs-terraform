resource "aws_iam_role" "ecs_host" {
  name               = "${local.name}-ecs-host"
  assume_role_policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            "ecs.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        },
        "Effect": "Allow"
      }
    ]
  })
  tags = {
    Name = "${local.name}-ecs-host"
  }
}

resource "aws_iam_role_policy" "ecs_instance" {
  name   = "${local.name}-ecs-instance"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecs:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "ecr:*",
          "cloudwatch:*",
          "s3:*",
          "rds:*",
          "logs:*"
        ],
        "Resource": "*"
      }
    ]
  })
  role   = aws_iam_role.ecs_host.id
}

resource "aws_iam_role" "ecs_service" {
  name               = "${local.name}-ecs-service"
  assume_role_policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            "ecs.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        },
        "Effect": "Allow"
      }
    ]
  })
  tags = {
    Name = "${local.name}-ecs-service"
  }
}

resource "aws_iam_role_policy" "ecs_service" {
  name   = "${local.name}-ecs-service"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
  role   = aws_iam_role.ecs_service.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = local.name
  path = "/"
  role = aws_iam_role.ecs_host.name
}

resource "aws_iam_role" "task_definition" {
  name               = "${local.name}-task-definition"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "task_definition" {
  name = "${local.name}-task-definition"
  role = aws_iam_role.task_definition.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ecr:GetAuthorizationToken",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "secretsmanager:GetSecretValue",
            "s3:*"
        ],
        "Resource": "*"
    }
  ]
}
POLICY
}
