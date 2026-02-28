extends Node
class_name EquipmentService

func list_equipment(category_filter: String = "") -> Dictionary:
	var query := "select=*"
	if not category_filter.is_empty():
		query += "&category=eq.%s" % category_filter
	query += "&order=name.asc"
	return await SupabaseClient.rest_select("equipment_items", query)

func check_out_item(item_id: String, holder_user_id: String, note: String = "") -> Dictionary:
	var update_result := await SupabaseClient.rest_update("equipment_items", "id=eq.%s" % item_id, {"current_holder_user_id": holder_user_id})
	if not update_result.ok:
		return update_result
	return await SupabaseClient.rest_insert("equipment_checkout_logs", [{
		"equipment_item_id": item_id,
		"action": "CHECK_OUT",
		"acted_by": AppState.user_id,
		"holder_user_id": holder_user_id,
		"note": note
	}])

func check_in_item(item_id: String, condition_status: String, note: String = "") -> Dictionary:
	var update_result := await SupabaseClient.rest_update("equipment_items", "id=eq.%s" % item_id, {
		"current_holder_user_id": null,
		"condition_status": condition_status
	})
	if not update_result.ok:
		return update_result
	return await SupabaseClient.rest_insert("equipment_checkout_logs", [{
		"equipment_item_id": item_id,
		"action": "CHECK_IN",
		"acted_by": AppState.user_id,
		"condition_status": condition_status,
		"note": note
	}])
