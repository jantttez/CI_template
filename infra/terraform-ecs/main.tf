data "aws_availability_zones" "zonez" {}

data "aws_ami" "ubuntu_latest" {
  owners      = ["image_Name"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-22.04-amd64-server-*"]
  }

}

resource "aws_ecs_cluster" "cluster_Name" {
  name       = var.project_name
  depends_on = [aws_autoscaling_group.ASGName]

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_autoscaling_group" "ASGName" {
  name                      = var.project_name + "asg"
  vpc_zone_identifier       = [var.default_subnet]
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 240

  launch_template {
    id      = aws_launch_template.ec2-template.id
    version = aws_launch_template.ec2-template.latest_version

  }

  depends_on = [aws_launch_template.ec2-template]

}


resource "aws_launch_template" "ec2-template" {

  name          = var.project_name + "es2_template"
  image_id      = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent
  }
  user_data = "#!/bin/bash\necho ECS CLUSTER=tClusterName >> /etc/ecs/ecs.config" //кидает агента в  каждую тачку
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecsAgent"
  role = aws_iam_role.ecs-agent


  depends_on = [aws_iam_role.ecs-agent]

}

resource "aws_iam_role" "ecs-agent" {
  name = "ecs"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"

      }
    ]
  })

}



resource "aws_iam_policy" "ecs_policy" {
  name = "ecs-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describelogs",
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:Submit*",
          "ecs:Poll*",
          "ecs:StartTask",
          "ecs:StartTelemetrySession",
          "ecs:StopTask",
          "ecs:UpdateService",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "s3:*",
          "rds:*",
          "logs:CreatelogStrean",
          "logs:PotLogEvent",
          "logs:DescribeLogStreans",
          "logs:CreateLogGroup",
          "logs:PutRetentinPolicy"
        ],
        Resource = "*"
      },

    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_policy.arn
  role       = aws_iam_role.ecs-agent.name

  depends_on = [aws_iam_role.ecs-agent,
  aws_iam_policy.ecs_policy]

}




resource "aws_ecs_task_definition" "Task" {

  family             = var.project_name + "task"
  execution_role_arn = aws_iam_role.ecs-agent.arn


  container_definitions = jsonencode([
    {
      name  = "container"
      image = "registry.gitlab.com/test2840711/teleubot:latest" //example


      cpu       = 500
      memory    = 700
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "eu-central-1"
          awslogs-group         = aws_cloudwatch_log_group.teleubot.name
          awslogs-stream-prefix = "ecs"
        }
      }


      environment = [
        { name = "GITLAB_USER", value = var.GITLAB_USER },
        { name = "GITLAB_TOKEN", value = var.GITLAB_PASSWORD }
      ]
    }
  ])



  depends_on = [aws_iam_role.ecs-agent,
  aws_cloudwatch_log_group.WatchGroup]

}


resource "aws_cloudwatch_log_group" "WatchGroup" {
  name = "teleubot" #либо /ecs/teleubot вместо teleubot

}

resource "aws_ecs_service" "teleubot" {
  name            = var.project_name
  cluster         = aws_ecs_cluster.teleubot.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.Task.arn

  depends_on = [aws_ecs_cluster.cluster_Name,
  aws_ecs_task_definition.Task]

}


