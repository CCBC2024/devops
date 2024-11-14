# Description: This script creates a security group and a load balancer for the charity donation application.

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# Disable pager for aws cli output to avoid manual intervention for large outputs.
# It is make sure the script runs without interruption
export AWS_PAGER=""

# Step 1: Create a security group
create_security_group "$security_group_name"

# Step 2: Add inbound rules that allow TCP traffic from any IPv4 address on ports 80.
add_inbound_rules_tcp_security_group "$security_group_name" 80

# Step 3: Add inbound rules that allow TCP traffic from any IPv4 address on ports 8080.
add_inbound_rules_tcp_security_group "$security_group_name" 8080

# Step 4: Create a load balancer
create_load_balancer "$load_balancer_name" "$security_group_name" "$public_subnet1_name" "$public_subnet2_name"

# Step 5: Create the listener listens on HTTP:80 and forward traffic to frontend-tg-two by default
create_listener "$load_balancer_name" "$listener_port_80" "$frontend_tg_two_name"

# Step 6: Create the listener listens on HTTP:8080 and forward traffic to frontend-tg-one by default.
create_listener "$load_balancer_name" "$listener_port_8080" "$frontend_tg_one_name"

# Step 7: Add rule to the listener 80
# Add a second rule for the HTTP:80 listener. Define the following logic for this new rule:
# - IF Path is /api/*
# - THEN Forward to... the backend-tg-two target group.
listener_80_arn=$(get_listener_arn "$load_balancer_name" "$listener_port_80")
add_rule_to_listener "$listener_80_arn" "$backend_path_pattern" "$backend_tg_two_name"

# Step 8: Add rule to the listener 8080
# Add a second rule for the HTTP:8080 listener. Define the following logic for this new rule:
# IF Path is /api/*
# THEN Forward to the backend-tg-one target group.
listener_8080_arn=$(get_listener_arn "$load_balancer_name" "$listener_port_8080")
add_rule_to_listener "$listener_8080_arn" "$backend_path_pattern" "$backend_tg_one_name"