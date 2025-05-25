# # variable "instance_id" {
# #   description = "Instance ID to fetch volume information"
# #   type        = string
# #   default     = ""
# # }

# # variable "root_snapshot_id" {
# #   description = "Manually specified root volume snapshot ID (optional)"
# #   type        = string
# #   default     = ""
# # }

# # variable "additional_snapshot_id" {
# #   description = "Manually specified additional volume snapshot ID (optional)"
# #   type        = string
# #   default     = ""
# # }

# # variable "snapshot_index" {
# #   description = "Nth most recent snapshot to use (1 = latest, 5 = fifth latest, etc.)"
# #   type        = number
# #   default     = 1
# # }

# # # Fetch Instance Details if instance_id is Provided
# # data "aws_instance" "this" {
# #   instance_id = var.instance_id
# # }

# # # Fetch All Available Snapshots for Root Volume
# # data "aws_ebs_snapshot" "root_snapshots" {
# #   count = length(var.root_snapshot_id) == 0 && length(var.instance_id) > 0 ? 1 : 0

# #   filter {
# #     name   = "volume-id"
# #     # values = [tolist(data.aws_instance.this.root_block_device)[0].volume_id]
# #     values = [tolist(data.aws_instance.this.root_block_device)[0].volume_id]

# #   }

# #   filter {
# #     name   = "status"
# #     values = ["completed"]
# #   }

# #   owners = ["self"]
# # }

# # # Fetch All Available Snapshots for Additional Volume
# # data "aws_ebs_snapshot" "extra_snapshots" {
# #   count = length(var.additional_snapshot_id) == 0 && length(var.instance_id) > 0 ? 1 : 0

# #   filter {
# #     name   = "volume-id"
# #     values = [for b in data.aws_instance.this.ebs_block_device : b.volume_id]
# #   }

# #   filter {
# #     name   = "status"
# #     values = ["completed"]
# #   }

# #   owners = ["self"]
# # }

# # # Select the nth Most Recent Snapshot for Root Volume
# # locals {
# #   root_snapshot_list = reverse(data.aws_ebs_snapshot.root_snapshots[*].id) # Reverse to get latest first
# #   selected_root_snapshot = length(local.root_snapshot_list) >= var.snapshot_index ? local.root_snapshot_list[var.snapshot_index - 1] : local.root_snapshot_list[0]
# # }

# # # Select the nth Most Recent Snapshot for Additional Volume
# # locals {
# #   extra_snapshot_list = reverse(data.aws_ebs_snapshot.extra_snapshots[*].id) # Reverse to get latest first
# #   selected_extra_snapshot = length(local.extra_snapshot_list) >= var.snapshot_index ? local.extra_snapshot_list[var.snapshot_index - 1] : local.extra_snapshot_list[0]
# # }

# # # Final Snapshot ID Selection (Use User Input if Provided, Else Auto-Select)
# # locals {
# #   final_root_snapshot_id       = length(var.root_snapshot_id) > 0 ? var.root_snapshot_id : local.selected_root_snapshot
# #   final_additional_snapshot_id = length(var.additional_snapshot_id) > 0 ? var.additional_snapshot_id : local.selected_extra_snapshot
# # }

# # # Create AWS AMI Using Selected Snapshots
# # resource "aws_ami" "this" {
# #   name                = var.AMI_name
# #   virtualization_type = var.virtualization_type
# #   root_device_name    = var.root_device_name
# #   ena_support         = true

# #   # Root Volume Snapshot
# #   ebs_block_device {
# #     device_name          = var.root_device_name
# #     snapshot_id          = local.final_root_snapshot_id
# #     volume_type          = var.volume_type
# #     volume_size          = var.root_volume_size
# #     delete_on_termination = true
# #   }

# #   # Additional Volume Snapshot
# #   ebs_block_device {
# #     device_name          = var.Extra_vol_device_name
# #     snapshot_id          = local.final_additional_snapshot_id
# #     volume_type          = var.volume_type
# #     volume_size          = var.Extra_volume_size
# #     delete_on_termination = false
# #   }

# #   tags = var.tags
# # }


# variable "instance_id" {
#   description = "Instance ID to fetch volume information"
#   type        = string
#   default     = ""
# }

# variable "root_snapshot_id" {
#   description = "Manually specified root volume snapshot ID (optional)"
#   type        = string
#   default     = ""
# }

# variable "additional_snapshot_id" {
#   description = "Manually specified additional volume snapshot ID (optional)"
#   type        = string
#   default     = ""
# }

# variable "snapshot_index" {
#   description = "Nth most recent snapshot to use (1 = latest, 5 = fifth latest, etc.)"
#   type        = number
#   default     = 1
# }

# # Fetch Instance Details if instance_id is Provided
# data "aws_instance" "this" {
#   instance_id = var.instance_id
# }

# # Fetch All Available Snapshots for Root Volume
# data "aws_ebs_snapshot" "root_snapshots" {
#   count = length(var.root_snapshot_id) == 0 && length(var.instance_id) > 0 ? 1 : 0

#   filter {
#     name   = "volume-id"
#     values = [data.aws_instance.this.root_block_device[0].volume_id]
#   }

#   filter {
#     name   = "status"
#     values = ["completed"]
#   }

#   owners = ["self"]
# }

# # Fetch All Available Snapshots for Additional Volume
# data "aws_ebs_snapshot" "extra_snapshots" {
#   count = length(var.additional_snapshot_id) == 0 && length(var.instance_id) > 0 ? 1 : 0

#   filter {
#     name   = "volume-id"
#     values = [for b in data.aws_instance.this.ebs_block_device : b.volume_id]
#   }

#   filter {
#     name   = "status"
#     values = ["completed"]
#   }

#   owners = ["self"]
# }

# # Sorting and selecting snapshots (ensure they are ordered correctly)
# locals {
#   sorted_root_snapshots = reverse(sort(data.aws_ebs_snapshot.root_snapshots[*].start_time))
#   root_snapshot_list    = [for snap in data.aws_ebs_snapshot.root_snapshots : snap.id if contains(local.sorted_root_snapshots, snap.start_time)]
#   selected_root_snapshot = length(local.root_snapshot_list) >= var.snapshot_index ? local.root_snapshot_list[var.snapshot_index - 1] : local.root_snapshot_list[0]
# }

# locals {
#   sorted_extra_snapshots = reverse(sort(data.aws_ebs_snapshot.extra_snapshots[*].start_time))
#   extra_snapshot_list    = [for snap in data.aws_ebs_snapshot.extra_snapshots : snap.id if contains(local.sorted_extra_snapshots, snap.start_time)]
#   selected_extra_snapshot = length(local.extra_snapshot_list) >= var.snapshot_index ? local.extra_snapshot_list[var.snapshot_index - 1] : local.extra_snapshot_list[0]
# }

# # Final Snapshot ID Selection (Use User Input if Provided, Else Auto-Select)
# locals {
#   final_root_snapshot_id       = length(var.root_snapshot_id) > 0 ? var.root_snapshot_id : local.selected_root_snapshot
#   final_additional_snapshot_id = length(var.additional_snapshot_id) > 0 ? var.additional_snapshot_id : local.selected_extra_snapshot
# }

# # Create AWS AMI Using Selected Snapshots
# resource "aws_ami" "this" {
#   name                = var.AMI_name
#   virtualization_type = var.virtualization_type
#   root_device_name    = var.root_device_name
#   ena_support         = true

#   # Root Volume Snapshot
#   ebs_block_device {
#     device_name          = var.root_device_name
#     snapshot_id          = local.final_root_snapshot_id
#     volume_type          = var.volume_type
#     volume_size          = var.root_volume_size
#     delete_on_termination = true
#   }

#   # Additional Volume Snapshot
#   ebs_block_device {
#     device_name          = var.Extra_vol_device_name
#     snapshot_id          = local.final_additional_snapshot_id
#     volume_type          = var.volume_type
#     volume_size          = var.Extra_volume_size
#     delete_on_termination = false
#   }

#   tags = var.tags
# }
