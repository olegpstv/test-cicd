variable "prefix" {
  type    = string
  default = "test"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "owner" {
  type    = string
  default = "oleh"
}

variable "ecr_repository_arn" {
  type    = string
  default = "arn:aws:ecr:eu-central-1:516669727885:repository/test-app"
}

variable "ecr_repository_url" {
  type = string
  default = "516669727885.dkr.ecr.eu-central-1.amazonaws.com/test-app"
}

variable "image_tag" {
  type    = string
  default = "latest"
}