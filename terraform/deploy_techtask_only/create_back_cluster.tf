resource "aws_launch_template" "ecs_back_launch" {
  name_prefix            = "ecs_back_launch"
  image_id               = data.aws_ami.aws_linux_latest_ecs.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.vpc_techtask_security_group.id]
  key_name               = data.aws_key_pair.keypair.key_name
  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${var.back_cluster_name} >> /etc/ecs/ecs.config;
    EOF
  )
  iam_instance_profile {
    arn = data.aws_iam_instance_profile.aws_iam_instance_profile_t.arn
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

}

resource "aws_ecs_capacity_provider" "back_capacity_provider" {
  name = "back-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_back_asg.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }

  tags = {
    Name = "back-ec2-capacity-provider"
  }
}

resource "aws_ecs_cluster_capacity_providers" "back_cluster_capacity_provider" {
  cluster_name       = var.back_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.back_capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.back_capacity_provider.name
    base              = 0
    weight            = 1
  }
}

resource "aws_autoscaling_group" "ecs_back_asg" {
  name = "ASGn-${aws_launch_template.ecs_back_launch.name_prefix}"
  launch_template {
    id      = aws_launch_template.ecs_back_launch.id
    version = aws_launch_template.ecs_back_launch.latest_version
  }
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 10
  vpc_zone_identifier       = data.aws_subnets.example.ids

  termination_policies = ["OldestInstance"]
  dynamic "tag" {
    for_each = {
      Name   = "Ecs-Back-Instance-ASG"
      Owner  = "Max Matveychuk"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  protect_from_scale_in = false
}

resource "aws_ecs_service" "back_services" {
  name                 = "back-services-${aws_ecs_task_definition.devrate_back_td.revision}"
  cluster              = var.back_cluster_name
  task_definition      = aws_ecs_task_definition.devrate_back_td.arn
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.back_capacity_provider.name
    base              = 1
    weight            = 100
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  lifecycle {
    create_before_destroy = true
  }
}