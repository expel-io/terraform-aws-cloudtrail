variable "prefix" {
  // TODO enforce max length with a validator
  description = "A prefix to group all Expel integration resources."
  default     = "expel-aws-integration"
}

variable "tags" {
  description = "A set of tags to group resources"
  default = {
    "vendor" : "expel"
  }
}
