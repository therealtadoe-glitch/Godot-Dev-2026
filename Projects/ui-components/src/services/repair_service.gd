extends Node
class_name RepairService

func submit_repair_ticket(payload: Dictionary) -> Dictionary:
	payload["created_by"] = AppState.user_id
	return await SupabaseClient.rest_insert("repair_tickets", [payload])

func update_repair_status(ticket_id: String, next_status: String, notes: String = "") -> Dictionary:
	var updates := {
		"status": next_status,
		"resolution_notes": notes
	}
	if next_status == "RESOLVED":
		updates["resolved_at"] = Time.get_datetime_string_from_system(true)
	return await SupabaseClient.rest_update("repair_tickets", "id=eq.%s" % ticket_id, updates)

func list_repairs(status_filter: String = "") -> Dictionary:
	var query := "select=*"
	if not status_filter.is_empty():
		query += "&status=eq.%s" % status_filter
	query += "&order=created_at.desc&limit=100"
	return await SupabaseClient.rest_select("repair_tickets", query)
