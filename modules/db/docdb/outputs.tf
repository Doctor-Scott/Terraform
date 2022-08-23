output "instance_name" {
  value = aws_docdb_cluster_instance.db[0].arn
}

output "docdb_endpoint" {
  value = aws_docdb_cluster_instance.db[0].endpoint
}