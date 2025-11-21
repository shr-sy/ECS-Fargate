output "ecr_repo_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "alb_dns_name" {
  description = "Load Balancer DNS Name"
  value       = module.alb.lb_dns_name
}

output "cluster_name" {
  description = "ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "service_name" {
  description = "ECS Service Name"
  value       = module.ecs.service_name
}
