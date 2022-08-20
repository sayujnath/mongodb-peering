# installs MongoDB in Amazon Linux 2

############################################################

#   Title:          example App AWS cloud resouces Phase 1
#   Author:         Sayuj Nath, AWS Solutions Architect
#   Company:        Canditude
#   Developed by:   Sayuj Nath
#   Prepared for    example Pty Ltd.
#                   Prepared for  public non-commercial use
#   Description:    Computing, Storage, Database Networking 
#                   and Securty resources required for 
#                   for Phase one of example Mobile API Application
#                   development and deployment using AWS
#                   public cloud resources.     
# 
#   File Desc:      Creates MongoDB Database ATLAS Database Cluster
#                   and database user credentials

#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. 

#                   For a production ready version,
#                   please contact the author at info@canditude.com
#                   Additional middleware is also required in application code to interact
#                   with the authorizaion servers 
#   Report:         

###########################################################


# The module creates the MongoDB Atlas cluster and their users
# Note that this module is using the Mongodb ATLAS provider
module "mongodb_module" {
    source = "../modules/mongoDB_module"

    dev_account = var.dev_account
    atlas_region = var.atlas_region
    type = var.type
    vpc_id = module.network_module.vpc.id
    vpc_cidr_block = var.cidr_block_prod
    cluster_name = var.cluster_name
    
    uat_vpc_id = module.uat_network_module.vpc.id
    uat_vpc_cidr_block = var.cidr_block_uat
    
    mongodb_cidr_block = var.mongodb_cidr_block

    mongodbatlas_public_key = var.mongodbatlas_public_key
    mongodbatlas_private_key = var.mongodbatlas_private_key
    atlasprojectid = var.atlasprojectid
    example_dev_instance_profile_arn = module.iam_module.example_dev_instance_profile.arn
    example_prod_instance_profile_arn = module.iam_module.example_prod_instance_profile.arn
}


# sets up private endpoints between various AWS and MongoDB ATLAS services
# to keep network traffic isolated from the public internet.
module "endpoints"  {
    source = "../modules/endpoints_module"
    region = var.region
    type = var.type
    vpc_id = module.network_module.vpc.id
    subnet_map = module.network_module.subnet_map
    security_group_map = module.security_module.security_group_map
    private_route_table_id = module.network_module.private_route_table.id
    mongodbatlas_peering_connection_id = module.mongodb_module.mongodbatlas_peering_connection_id
    mongodb_cidr_block = var.mongodb_cidr_block
}
