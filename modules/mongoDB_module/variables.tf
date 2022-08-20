
variable dev_account {
    type = string
    default = ""
    description = "This is the number of the development account which owns the AMI that will be used"
}

variable atlas_region {
    type    = string
    description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones."
        validation {
        condition     = contains(["AP_SOUTHEAST_2"], var.atlas_region)
        error_message = "Allowed values for 'region' parameter are 'us-east-1' and 'ap-southeast-2'."
    }
}

variable type {
    type = string
    validation {
        condition     = contains(["dev", "test", "stage", "prod", "all", "sync"], var.type)
        error_message = "Allowed values for 'type' parameter are 'dev', 'test', 'prod' or all."
    }
}

variable "vpc_id" {
    type = string
    description = "This is the id of the vpc created in the network module"
}

variable "cluster_name" {
    type = string
    description = "This is the name of the MongoDB ATLAS cluster"
}

variable vpc_cidr_block {
    type    = string
    description = "This will the CIDR block of the application VPC."
}


variable "uat_vpc_id" {
    type = string
    description = "This is the id of the uat vpc created in the uat network module"
}

variable uat_vpc_cidr_block {
    type    = string
    description = "This will the CIDR block of the UAT application VPC."
}


variable mongodb_cidr_block {
    type    = string
    description = "This will the CIDR block of the MongoDB ATLAS VPC."
}



variable "mongodbatlas_public_key" {
    type = string
    description = "The public key to the database"
}

variable "mongodbatlas_private_key" {
    type = string
    description = "The private key to the database"
}


variable "atlasprojectid" {
    description = "Atlas project ID"
}


# variable "atlasorgid" {

#     description = "Atlas Org ID"
# }
# variable "atlas_vpc_cidr" {
#     description = "Atlas CIDR"
# }

# The following two variables example_dev_instance_profile_arn and  example_prod_instance_profile_arnare 
# unusd in MongoDB 4.2, To use, please upgrate to MongoDB 4.4 which support instance profiles for authenticaltion
variable "example_dev_instance_profile_arn" {
    type = string
    description = "This is the ARN of the instance profile of the role used by the Development and Tesr EC2 servers"
}

variable "example_prod_instance_profile_arn" {
    type = string
    description = "This is the ARN of the instance profile of the role used by the production EC2 cluster"
}

# variable mongoDB_user_data  {
#     type = map
#     description = "Map of user names, pem file name and random passwords for the users"
# }