

output "Event_Hub_Namespace" {
  description = "Event Hub Namespace"
  value       = "${azurerm_eventhub_namespace.event_namespace1.name}"
}


#output "Event_Hub" {
#  description = "Event Hub"
#  value       = "${azurerm_eventhub.event_hub1.name}"
#}



output "Event_hub_private_link" {
  description = "PRIVATELINK EVENTHUBNAMESPACE"
  value = data.azurerm_private_endpoint_connection.ktest-event-endpoint-connection.private_service_connection.0.private_ip_address
}

