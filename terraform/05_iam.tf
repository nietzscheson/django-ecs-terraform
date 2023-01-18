resource "aws_iam_role" "ecs_host" {
  name               = "${local.name}-ecs-host"
  # assume_role_policy = file("policies/ecs-role.json")
  assume_role_policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            # "ecs.amazonaws.com",
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
  # policy = file("policies/ecs-instance-role-policy.json")
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
  # assume_role_policy = file("policies/ecs-role.json")
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
  # policy = file("policies/ecs-service-role-policy.json")
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
