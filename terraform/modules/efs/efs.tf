resource "aws_efs_file_system" "efs_fs" {
    performance_mode    = var.performance_mode
    encrypted           = var.encrypted

}
resource "aws_efs_mount_target" "efs_mount_target" {
    count           = length(var.target_subnets) > 0 ? length(var.target_subnets) : 0

    file_system_id  = aws_efs_file_system.efs_fs.id
    subnet_id       = var.target_subnets[count.index]
}
