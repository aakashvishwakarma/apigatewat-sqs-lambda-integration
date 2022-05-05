 variable "function_name" {
   type = string
   description = "The name of lambda function"
   default = "Demo-function"
 }
variable "environment"{
type = string
default = "test"
description = "Value of common tag variable hold the environment variable"
}

variable "team"{
type = string
default = "POC"
description = "Value of common tag variable hold the team name variable"
}
variable "platform_name"{
type = string
default = "Demo"
description = "Value of common tag variable hold the platform_name variable"

}

variable "region" {
  default = "us-east-1"
}