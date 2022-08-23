output "instance_name" {
  value = aws_docdb_cluster_instance.db.arn
}

output "rds_endpoint" {
  value = aws_docdb_cluster_instance.db.endpoint
}