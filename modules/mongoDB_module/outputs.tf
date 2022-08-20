output "mongodbatlas_peering_connection_id" {
    value = mongodbatlas_network_peering.mongodb_peer.connection_id
    description = "VPC peering Connection ID for the MongoDB Atlas cluster"
}

output "uat_mongodbatlas_peering_connection_id" {
    value = mongodbatlas_network_peering.uat_mongodb_peer.connection_id
    description = "VPC peering Connection ID for the MongoDB Atlas cluster"
}


output "mongodb_credentials"    {
    value = {
        users = local.user_names
        pwds = local.all_passwords
        example_db_dev_pwd = random_password.example_db_dev_pwd.result
        example_db_prod_pwd = random_password.example_db_prod_pwd.result
    }
    description = "List of all mongodb atlas cluster user names and passwords"
    sensitive = true
}

output "mongodb_connection_strings"    {
    value = mongodbatlas_cluster.prod-db.connection_strings
    description = "Map of all connection strings needs to connect with the cluster"
}
