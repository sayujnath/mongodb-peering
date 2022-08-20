

variable "atlas_region" {
    type    = string
    description = "Set this to the region to deploy resources. Ensure the region has at least three availiability zones."
        validation {
        condition     = contains(["AP_SOUTHEAST_2"], var.atlas_region)
        error_message = "Allowed values for 'region' parameter are 'us-east-1' and 'ap-southeast-2'."
    }
}

variable "cluster_name" {
    type = string
    description = "This is the name of the MongoDB ATLAS cluster"
}

variable "mongodb_cidr_block" {
    type = string
    description = "CIDR block of the MongoDB Atlas cluster"
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