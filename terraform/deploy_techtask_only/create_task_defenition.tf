resource "aws_ecs_task_definition" "devrate_back_td" {

  family = "devrate_back_td"

  container_definitions = jsonencode([
    {
      name              = "back-container",
      image             = "${data.aws_caller_identity.current_user.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.back_repository_name}:${var.image_tag}",
      cpu               = 0,
      memory            = 819,
      memoryReservation = 819,
      portMappings = [
        {
          name          = "back-container-${var.back_port}-tcp",
          containerPort = var.back_port,
          hostPort      = var.back_port,
          protocol      = "tcp",
          appProtocol   = "http"
        }
      ],
      essential = true,
      environment = [
        {
          name  = "POSTGRES_USER",
          value = "techtaskDB"
        },
        {
          name  = "PG_USERNAME",
          value = "techtaskDB"
        },
        #         {
        #           name  = "PG_HOST",
        #           value =
        #         },
        {
          name  = "PG_PASSWORD",
          value = "techtaskDB"
        },
        {
          name  = "PG_DATABASE",
          value = "techtaskDB"
        },
        {
          name  = "POSTGRES_PASSWORD",
          value = "techtaskDB"
        },
        {
          name  = "POSTGRES_DB",
          value = "techtaskDB"
        }
      ],
      mountPoints = [],
      volumesFrom = [],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/back-container",
          awslogs-create-group  = "true",
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        },
        secretOptions = []
      },
      systemControls = []
    }
  ])

  task_role_arn      = data.aws_iam_role.ecs_task_execution_role_arn.arn
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role_arn.arn
  network_mode       = "bridge"
  requires_compatibilities = [
    "EC2"
  ]
  cpu    = "1024"
  memory = "923"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}