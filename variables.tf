variable "ibmcloud_api_key" {
  type        = string
  description = "Please enter the IBM Cloud API key."
  sensitive   = true
}


variable "ssh_key" {
  type        = string
  description = "Enter your IBM cloud ssh key name."
}

variable "region" {
  description = "Please enter a region from the following available region and zones mapping: \nus-south\nus-east\neu-gb\neu-de\njp-tok\nau-syd"
  type        = string
}


variable "resource_group_id" {
  type        = string
  description = "Resource Group ID"
}

variable "home_fs_size" {
  type        = string
  description = "Volume size"
}

