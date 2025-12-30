variable "image_name" {
  type        = string
  description = "ACR repository name, e.g. cv-analyser"
}

variable "image_tag" {
  type        = string
  description = "Image tag, e.g. Git SHA"
}
