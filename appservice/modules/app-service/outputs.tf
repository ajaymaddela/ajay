output "service_plan_id" {
  value = azurerm_service_plan.main.id
}

output "linux_web_app_id" {
  value = azurerm_linux_web_app.main[0].id
}
