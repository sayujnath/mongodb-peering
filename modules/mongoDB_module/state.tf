terraform {
  required_providers {
        mongodbatlas = {
            source  = "mongodb/mongodbatlas"
            version = "~> 0.9.0"
        }
    }
}


# Configure the MongoDB Atlas Provider
provider "mongodbatlas" {
    public_key = var.mongodbatlas_public_key
    private_key  = var.mongodbatlas_private_key
}