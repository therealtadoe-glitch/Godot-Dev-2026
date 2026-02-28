extends Node
class_name DashboardController

signal clock_state_changed(is_clocked_in: bool)
signal error_raised(message: String)

@onready var time_service := TimeTrackingService.new()

func _ready() -> void:
	add_child(time_service)

func refresh_clock_state() -> void:
	var result := await time_service.get_my_open_entry()
	if not result.ok:
		error_raised.emit("Could not fetch open time entry")
		return
	var entries: Array = result.data if result.data is Array else []
	clock_state_changed.emit(entries.size() > 0)

func perform_clock_in(village_id: String, job_site_id: String, crew_id: String) -> void:
	var result := await time_service.clock_in(village_id, job_site_id, crew_id)
	if not result.ok:
		error_raised.emit("Clock in failed")
		return
	clock_state_changed.emit(true)

func perform_clock_out(entry_id: String) -> void:
	var result := await time_service.clock_out(entry_id)
	if not result.ok:
		error_raised.emit("Clock out failed")
		return
	clock_state_changed.emit(false)
