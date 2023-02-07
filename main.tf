provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "example" {
  name = "example"
}

locals {
  image_repository = "${aws_ecr_repository.example.repository_url}"
}

provisioner "local-exec" {
  command = "docker build -t ${local.image_repository}:latest ."
}

resource "aws_ecs_task_definition" "example" {
  family = "example"
  container_definitions = <<DEFINITION
[
  {
    "name": "example",
    "image": "${local.image_repository}:latest",
    "cpu": 128,
    "memory": 256,
    "essential": true
  }
]
DEFINITION
}

resource "aws_ecs_service" "example" {
  name            = "example"
  task_definition = "${aws_ecs_task_definition.example.arn}"
  desired_count   = 1
  cluster         = "default"
}
