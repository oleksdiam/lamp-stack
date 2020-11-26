variable "performance_mode" {
    description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO' (Default: 'generalPurpose')."
    default     = "generalPurpose"
}

variable "encrypted" {
    description = "If true, the disk will be encrypted."
    default     = true
}

variable "target_subnets" {
    description = "The ID of the subnets to add the mount target in."
    type        = list
    default     = []
}
