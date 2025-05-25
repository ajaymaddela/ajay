output "primary_sql_server_id" {
  value = azurerm_mssql_database.main.id
}

output "sql_database_id" {
  value = azurerm_mssql_database.main.id
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.sql_private_endpoint.id
}