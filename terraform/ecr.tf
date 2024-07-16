data "aws_ecr_lifecycle_policy_document" "django" {
  rule {
    priority    = 1
    description = "Retain last 3 images"

    selection {
      tag_status      = "any"
      count_type      = "imageCountMoreThan"
      count_number    = 3
    }

    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_repository" "django" {
  name                 = "${local.name}-django"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    ignore_changes        = all
    create_before_destroy = true
  }

  
}

resource "aws_ecr_lifecycle_policy" "django" {
  repository = aws_ecr_repository.django.name
  policy     = data.aws_ecr_lifecycle_policy_document.django.json
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = <<-EOF
      if [ $(aws ecr list-images --repository-name ${aws_ecr_repository.django.name} --region ${var.region} | jq '.imageIds | length') -gt 0 ]; then
        echo "Repository has content, skipping."
      else
        echo "Repository is empty, executing commands."
        aws ecr get-login-password --region ${var.region} | docker login -u AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
        docker pull alpine
        docker tag alpine ${aws_ecr_repository.django.repository_url}:latest
        docker push ${aws_ecr_repository.django.repository_url}:latest
      fi
    EOF
  }


  triggers = {
    "run_at" = timestamp()
  }


  depends_on = [
    aws_ecr_repository.django,
  ]
}