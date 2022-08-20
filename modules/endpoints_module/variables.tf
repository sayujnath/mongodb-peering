variable region {
    type    = string
    description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones."
        validation {
        condition     = contains(["us-east-1", "us-east-2", "ap-southeast-2"], var.region)
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


variable "security_group_map" {
    type = map
    description = "The map of all the security groups for each tier."
}

variable "subnet_map"   {
    type = map
    description = "Map of all the vpc subnets"

}


variable "private_route_table_id" {
    type = string
    description = "This is the route table for the private subnets"
}


variable "mongodbatlas_peering_connection_id" {
    type = string
    description = "VPC peering Connection ID for the MongoDB Atlas cluster"
}


variable "mongodb_cidr_block" {
    type = string
    description = "CIDR block of the MongoDB Atlas cluster"
}
