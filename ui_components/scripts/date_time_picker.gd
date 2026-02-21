extends AdaptiveUIComponent
class_name DateTimePicker

signal date_time_changed(selected: Dictionary)

@export var use_24h: bool = false

var _calendar := Calendar.new()
var _year_spin := SpinBox.new()
var _month_options := OptionButton.new()
var _hour_spin := SpinBox.new()
var _minute_spin := SpinBox.new()
var _am_pm := OptionButton.new()

func _build_ui() -> void:
	name = "DateTimePicker"
	var root := VBoxContainer.new()
	root.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(root)

	_calendar.size_flags_horizontal = SIZE_EXPAND_FILL
	root.add_child(_calendar)

	var row := HBoxContainer.new()
	row.name = "TimeRow"
	row.size_flags_horizontal = SIZE_EXPAND_FILL
	root.add_child(row)

	_setup_month_dropdown()
	row.add_child(_month_options)

	_year_spin.min_value = 1970
	_year_spin.max_value = 2100
	_year_spin.step = 1
	_year_spin.custom_minimum_size.x = 90
	_year_spin.value = Time.get_datetime_dict_from_system().year
	row.add_child(_year_spin)

	_hour_spin.min_value = 0 if use_24h else 1
	_hour_spin.max_value = 23 if use_24h else 12
	_hour_spin.step = 1
	_hour_spin.custom_minimum_size.x = 70
	row.add_child(_hour_spin)

	_minute_spin.min_value = 0
	_minute_spin.max_value = 59
	_minute_spin.step = 1
	_minute_spin.custom_minimum_size.x = 70
	row.add_child(_minute_spin)

	_am_pm.add_item("AM")
	_am_pm.add_item("PM")
	_am_pm.visible = not use_24h
	row.add_child(_am_pm)

	if not _calendar.day_selected.is_connected(_emit_date_time):
		_calendar.day_selected.connect(_emit_date_time)
	for widget in [_year_spin, _month_options, _hour_spin, _minute_spin, _am_pm]:
		if widget.has_signal("value_changed"):
			widget.value_changed.connect(_emit_date_time)
		elif widget.has_signal("item_selected"):
			widget.item_selected.connect(_emit_date_time)

	_set_defaults_from_system()

func _refresh_layout() -> void:
	var row := get_node_or_null("VBoxContainer/TimeRow")
	if row:
		row.add_theme_constant_override("separation", get_adaptive_padding() / 2)

func get_selected_date_time() -> Dictionary:
	var dt := _calendar.get_date()
	var hour := int(_hour_spin.value)
	if not use_24h:
		if _am_pm.selected == 1 and hour < 12:
			hour += 12
		if _am_pm.selected == 0 and hour == 12:
			hour = 0
	return {
		"year": int(_year_spin.value),
		"month": _month_options.selected + 1,
		"day": dt.day,
		"hour": hour,
		"minute": int(_minute_spin.value)
	}

func _setup_month_dropdown() -> void:
	_month_options.clear()
	for month in ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]:
		_month_options.add_item(month)

func _set_defaults_from_system() -> void:
	var now := Time.get_datetime_dict_from_system()
	_calendar.set_date(now.year, now.month, now.day)
	_year_spin.value = now.year
	_month_options.selected = now.month - 1
	if use_24h:
		_hour_spin.value = now.hour
	else:
		_am_pm.selected = 1 if now.hour >= 12 else 0
		var normalized := now.hour % 12
		_hour_spin.value = 12 if normalized == 0 else normalized
	_minute_spin.value = now.minute

func _emit_date_time(_unused = null) -> void:
	var selected := get_selected_date_time()
	_calendar.set_date(selected.year, selected.month, selected.day)
	emit_signal("date_time_changed", selected)
