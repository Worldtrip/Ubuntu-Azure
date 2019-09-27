variable "loc" {
    description = "Default Azure region"
    default     =   "West Europe"
}

variable "tags" {
    default     = {
        source  = "ubuntu"
        env     = "training"
    }
}
variable "vm" {
    default     = {
        server-name  = "ubuntu-test"
        env     = "training"
    }
}