extends Node
class_name TimeTrackingService

func clock_in(village_id: String, job_site_id: String, crew_id: String = "") -> Dictionary:
	var payload := [{
		"user_id": AppState.user_id,
		"village_id": village_id,
		"job_site_id": job_site_id,
		"crew_id": crew_id,
		"clock_in_at": Time.get_datetime_string_from_system(true)
	}]
	return await SupabaseClient.rest_insert("time_entries", payload)

func clock_out(open_entry_id: String) -> Dictionary:
	var updates := {"clock_out_at": Time.get_datetime_string_from_system(true)}
	var query := "id=eq.%s" % open_entry_id
	return await SupabaseClient.rest_update("time_entries", query, updates)

func get_my_open_entry() -> Dictionary:
	var query := "select=*&user_id=eq.%s&clock_out_at=is.null&order=clock_in_at.desc&limit=1" % AppState.user_id
	return await SupabaseClient.rest_select("time_entries", query)

func get_my_entries_for_day(date_iso: String) -> Dictionary:
	var start := "%sT00:00:00Z" % date_iso
	var end := "%sT23:59:59Z" % date_iso
	var query := "select=*&user_id=eq.%s&clock_in_at=gte.%s&clock_in_at=lte.%s&order=clock_in_at.asc" % [AppState.user_id, start, end]
	return await SupabaseClient.rest_select("time_entries", query)
