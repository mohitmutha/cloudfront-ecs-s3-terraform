resource "aws_ecs_cluster" "my_cluster" {
   name = "my_cluster"
 }

 resource "aws_ecs_task_definition" "my_api" {
  family = "my-api"
  execution_role_arn = aws_iam_role.my_api_task_execution_role.arn
  container_definitions = <<EOF
  [
    {
      "name": "my-api",
      "image": "mohitmutha/simplefastifyservice:1.1",
      "portMappings": [
        {
          "containerPort": 3000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "eu-central-1",
          "awslogs-group": "/ecs/my-api",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  EOF
# These are the minimum values for Fargate containers.
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
}

resource "aws_cloudwatch_log_group" "my_api" {
  name = "/ecs/my-api"
}

resource "aws_iam_role" "my_api_task_execution_role" {
  name               = "my-api-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is
# an AWS-managed policy, it's okay.
data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.my_api_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "my_api" {
  name            = "my-api"
  task_definition = aws_ecs_task_definition.my_api.arn
  cluster         = aws_ecs_cluster.my_cluster.id
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = aws_lb_target_group.my_api.arn
    container_name   = "my-api"
    container_port   = "3000"
  }
  desired_count = 1
  network_configuration {
   assign_public_ip = false
security_groups = [
     aws_security_group.egress_all.id,
     aws_security_group.ingress_api.id,
   ]
subnets = [
     aws_subnet.private_a.id
   ]
 }
}