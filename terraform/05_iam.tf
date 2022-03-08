resource "aws_iam_role" "ecs-host-role" {
  name               = "${var.name}-ecs-host"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs-instance-role-policy" {
  name   = "${var.name}-ecs-instance-role"
  policy = file("policies/ecs-instance-role-policy.json")
  role   = aws_iam_role.ecs-host-role.id
}

resource "aws_iam_role" "ecs-service-role" {
  name               = "${var.name}-ecs-service"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs-service-role-policy" {
  name   = "${var.name}-ecs-service-role"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs-service-role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.name}-ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-host-role.name
}
