# Deploying Django to AWS ECS with Terraform

Sets up the following AWS infrastructure:

- Networking:
    - VPC
    - Public and private subnets
    - Routing tables
    - Internet Gateway
    - Key Pairs
- Security Groups
- Load Balancers, Listeners, and Target Groups
- IAM Roles and Policies
- ECS:
    - Task Definition (with multiple containers)
    - Cluster
    - Service
- ECR:
    - Django Image
    - Nginx Image
- Launch Config and Auto Scaling Group
- RDS
- Health Checks and Logs

## Want to learn how to build this?

Check out the [post](https://testdriven.io/blog/deploying-django-to-ecs-with-terraform/).

## Want to use this project?

1. Install Terraform

1. Sign up for an AWS account

1. Fork/Clone

1. Update the variables in *terraform/variables.tf*.

1. Set the following environment variables, init Terraform, create the infrastructure:

    ```sh
    $ cd terraform
    $ export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
    $ export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"

    $ terraform init
    $ terraform apply
    $ cd ..
    ```

1. Terraform will output an ALB domain. Create a CNAME record for this domain
   for the value in the `allowed_hosts` variable.

1. You can also run the following script to bump the Task Definition and update the Service:

    ```sh
    $ cd deploy
    $ python update-ecs.py --cluster=<cluster-name> --service=<service-name>
    ```
