extends Node
class_name TicketService

func create_ticket(payload: Dictionary) -> Dictionary:
	payload["created_by"] = AppState.user_id
	return await SupabaseClient.rest_insert("work_tickets", [payload])

func update_ticket_status(ticket_id: String, next_status: String) -> Dictionary:
	var updates := {"status": next_status}
	if next_status == "IN_PROGRESS":
		updates["started_at"] = Time.get_datetime_string_from_system(true)
	elif next_status == "COMPLETE":
		updates["completed_at"] = Time.get_datetime_string_from_system(true)
	return await SupabaseClient.rest_update("work_tickets", "id=eq.%s" % ticket_id, updates)

func assign_employee(ticket_id: String, employee_id: String) -> Dictionary:
	var payload := [{
		"ticket_id": ticket_id,
		"employee_id": employee_id,
		"assigned_by": AppState.user_id
	}]
	return await SupabaseClient.rest_insert("work_ticket_assignments", payload)

func list_tickets(status_filter: String = "") -> Dictionary:
	var query := "select=*"
	if not status_filter.is_empty():
		query += "&status=eq.%s" % status_filter
	query += "&order=created_at.desc&limit=100"
	return await SupabaseClient.rest_select("work_tickets", query)
