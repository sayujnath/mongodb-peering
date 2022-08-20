
#                   This version of the code is incomplete &untested and specially released 
#                   for non-commecial public consumption. 

#                   For a production ready version,
#                   please contact the author at info@canditude.com
#                   Additional middleware is also required in application code to interact
#                   with the authorizaion servers 

# ############################## MONGODB ATLAS################################
# ############################### SUBNET PEERING #############################
# the following assumes an AWS provider is configured
# Accept the peering connection request
resource "aws_vpc_peering_connection_accepter" "atlas_peer" {
    vpc_peering_connection_id = var.mongodbatlas_peering_connection_id
    auto_accept = true
    lifecycle {
        ignore_changes = all
    }

}

resource "aws_route"  "mongodb_vpc_route"{
    route_table_id            = var.private_route_table_id
    destination_cidr_block    = var.mongodb_cidr_block
    vpc_peering_connection_id = var.mongodbatlas_peering_connection_id
    
}

resource "aws_vpc_peering_connection_options" "sb_vpc_peering_options" {
    vpc_peering_connection_id = aws_vpc_peering_connection_accepter.atlas_peer.id

    accepter {
        allow_remote_vpc_dns_resolution = true
    }

}


####################### CLOUDWATCH VPC  INTERFACE #########################
############################### ENDPOINT ##################################

resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
    vpc_id            = var.vpc_id
    service_name      = "com.amazonaws.${var.region}.monitoring"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        var.security_group_map.web.id,
        var.security_group_map.app_dev.id,
        var.security_group_map.app_test.id,
        var.security_group_map.app_prod.id
    ]
    
    subnet_ids = [var.subnet_map.app.A.id]

    private_dns_enabled = true
    tags = {
        Name = "cloudwatch-app-interface"
        Environment = var.type
        GeneratedBy = "terraform"
        PreparedBy = "canditude"
    }
}



###################### CODE DEPLOY VPC  INTERFACE #########################
############################## ENDPOINT ##################################

resource "aws_vpc_endpoint" "code_deploy_agent_endpoint" {
    vpc_id            = var.vpc_id
    service_name      = "com.amazonaws.${var.region}.codedeploy-commands-secure"
    vpc_endpoint_type = "Interface"

    security_group_ids = [  var.security_group_map.app_dev.id, 
                            var.security_group_map.app_test.id,
                            var.security_group_map.app_prod.id
                        ]    # TODO replace with app    
    subnet_ids = [ var.subnet_map.app.A.id ]                # TODO replace with app   # For production add - var.subnet_map.app.B.id, var.subnet_map.app.C.id 


    private_dns_enabled = true
    tags = {
        Name = "code_deploy_agent-interface"
        Environment = var.type
        GeneratedBy = "terraform"
        PreparedBy = "canditude"
    }
}

########################### SSM VPC INTERFACE #########################
############################## ENDPOINT ##################################
resource "aws_vpc_endpoint" "ssm_endpoint" {
    vpc_id            = var.vpc_id
    service_name      = "com.amazonaws.${var.region}.ssm"
    vpc_endpoint_type = "Interface"

    security_group_ids = [  var.security_group_map.app_dev.id, 
                            var.security_group_map.app_test.id,
                            var.security_group_map.app_prod.id]    # TODO replace with app    
    subnet_ids = [ var.subnet_map.app.A.id ]                # TODO replace with app   # For production add - var.subnet_map.app.B.id, var.subnet_map.app.C.id 


    private_dns_enabled = true
    tags = {
        Name = "ssm-interface"
        Environment = var.type
        GeneratedBy = "terraform"
        PreparedBy = "canditude"
    }
}


############################## S3 GATEWAY ################################
############################### ENDPOINT #################################

# This gateway endpoint gives provides private access from private subnets
# to S3 buckets where files are stored.
resource "aws_vpc_endpoint" "s3_endpoint" {
    vpc_id       = var.vpc_id
    service_name = "com.amazonaws.${var.region}.s3"

    tags = {
        Name = "s3-app-gateway"
        Environment = var.type
        GeneratedBy = "terraform"
        PreparedBy = "canditude"
    }
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_route" {
    route_table_id  = var.private_route_table_id
    vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}


