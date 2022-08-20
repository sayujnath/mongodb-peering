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
#   Design Report:  not released to public

###########################################################

# This is the MongoDB Cluster resources which contains three databases
# development, test and production
resource "mongodbatlas_cluster" "prod-db" {

    lifecycle {
            prevent_destroy = true
            ignore_changes = [provider_instance_size_name,
                                provider_disk_iops]
    }
    
    project_id                   = var.atlasprojectid
    name                         = var.cluster_name
    num_shards                   = 1
    replication_factor           = 3
    provider_backup_enabled      = true
    auto_scaling_disk_gb_enabled = true
    auto_scaling_compute_enabled = true
    auto_scaling_compute_scale_down_enabled = true
    mongo_db_major_version       = "4.2"

    //Provider settings
    provider_name               = "AWS"
    disk_size_gb                = 30
    provider_disk_iops          = 1000
    provider_volume_type        = "STANDARD"
    # provider_encrypt_ebs_volume = true
    provider_instance_size_name = "M10"
    provider_region_name        = var.atlas_region
}


# Create the peering connection request to the prod vpc
resource "mongodbatlas_network_peering" "mongodb_peer" {
    accepter_region_name   = var.atlas_region
    project_id             = var.atlasprojectid
    container_id           = mongodbatlas_cluster.prod-db.container_id
    provider_name          = "AWS"
    route_table_cidr_block = var.vpc_cidr_block
    vpc_id                 = var.vpc_id
    aws_account_id         = var.dev_account
    lifecycle {
        ignore_changes = all
    }
}

# Create the peering connection request to the UAT VPC
resource "mongodbatlas_network_peering" "uat_mongodb_peer" {
    accepter_region_name   = var.atlas_region
    project_id             = var.atlasprojectid
    container_id           = mongodbatlas_cluster.prod-db.container_id
    provider_name          = "AWS"
    route_table_cidr_block = var.uat_vpc_cidr_block
    vpc_id                 = var.uat_vpc_id
    aws_account_id         = var.dev_account
    lifecycle {
        ignore_changes = all
    }
}


# This user is used by the Development and Test instances in AWS
resource "mongodbatlas_database_user" "example_db_dev" {

    username           = "example_db_dev"
    password           = random_password.example_db_dev_pwd.result
    project_id         = var.atlasprojectid
    auth_database_name = "admin"

    # cannot use IAM role unless MongoDB 4.4 or higher is used
    # username           = var.example_dev_instance_profile_arn
    # project_id         = var.atlasprojectid
    # auth_database_name = "$external"
    # aws_iam_type       = "ROLE"

    lifecycle {
            prevent_destroy = true
            ignore_changes = [
              roles,
              password
            ]
    }

    roles {
        role_name     = "readWrite"
        database_name = "example_database_dev"
    }

    roles {
        role_name     = "readWrite"
        database_name = "example_database_test"
    }

    roles {
        role_name     = "readAnyDatabase"
        database_name = "admin"
    }

    labels {
        key   = "PreparedBy"
        value = "canditude"
    }

    labels {
        key   = "GeneratedBy"
        value = "terraform"
    }


    scopes {
        name   = mongodbatlas_cluster.prod-db.name
        type = "CLUSTER"
    }
}

# This user is used by the Production instances in AWS
resource "mongodbatlas_database_user" "example_db_prod" {

    username           = "example_db_prod"
    password           = random_password.example_db_prod_pwd.result
    project_id         = var.atlasprojectid
    auth_database_name = "admin"

    # cannot use IAM role unless MongoDB 4.4 or higher is used
    # username           = var.example_prod_instance_profile_arn
    # project_id         = var.atlasprojectid
    # auth_database_name = "$external"
    # aws_iam_type       = "ROLE"
    lifecycle {
            prevent_destroy = false
            ignore_changes = [
              roles,
              password
            ]
    }

    roles {
        role_name     = "readWrite"
        database_name = "example_database_live"
    }

    labels {
        key   = "PreparedBy"
        value = "canditude"
    }

    labels {
        key   = "GeneratedBy"
        value = "terraform"
    }

    scopes {
        name   = mongodbatlas_cluster.prod-db.name
        type = "CLUSTER"
    }
}


locals  {

    # get all the .ppk and pem files in .security/keys/dev folder
    file_names = fileset("${path.module}/../.security/keys/dev/mac/","**.pem")

    # removing extension from file "ppk and "pem"
    user_names = [for name in local.file_names: trimsuffix(name,".pem")]

    all_passwords = [for pwd in random_password.password: pwd]
    
}

# Creates database user credentials with developer access
resource "mongodbatlas_database_user" "db_users" {
    for_each = local.file_names

    username           = replace(trimsuffix(each.key,".pem"),".","-")
    password           = element(tolist(local.all_passwords), index(local.user_names, trimsuffix(each.key,".pem"))).result
    project_id         = var.atlasprojectid
    auth_database_name = "admin"

    lifecycle {
            prevent_destroy = false
            ignore_changes = [
              roles,
              password
            ]
    }

    roles {
        role_name     = "readWrite"
        database_name = "example_database_dev"
    }

    roles {
        role_name     = "readWrite"
        database_name = "example_database_test"
    }

    roles {
        role_name     = "read"
        database_name = "example_database_live"
    }

    roles {
        role_name     = "readAnyDatabase"
        database_name = "admin"
    }

    labels {
        key   = "PreparedBy"
        value = "canditude"
    }

    labels {
        key   = "GeneratedBy"
        value = "terraform"
    }


    scopes {
        name   = mongodbatlas_cluster.prod-db.name
        type = "CLUSTER"
    }

}

# creates a password for each user
resource "random_password" "password" {
    for_each = local.file_names

    lifecycle {
            prevent_destroy = false
    }

    length = 20
    special = false
    upper = true
    override_special = "-"
}

resource "random_password" "example_db_dev_pwd" {
    
    lifecycle {
            prevent_destroy = true
    }

    length = 20
    special = false
    upper = true
    override_special = "-"
}

# generates a rando password for the production user
resource "random_password" "example_db_prod_pwd" {
    
    lifecycle {
            prevent_destroy = true
    }
    
    length = 20
    special = false
    upper = true
    override_special = "-"
}
