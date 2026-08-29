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

variable "github_repo" {
  type        = string
  default     = "olegpstv@92054329/test-cicd@1349491600"
  description = "OWNER/REPO - попадает в sub-условие trust policy"
}