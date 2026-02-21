extends AdaptiveUIComponent
class_name CommandPalette

signal command_chosen(command_id: String)

var _backdrop := ColorRect.new()
var _panel := PanelContainer.new()
var _search := LineEdit.new()
var _list := ItemList.new()
var _commands: Array[Dictionary] = []

func _build_ui() -> void:
	visible = false
	z_index = 140
	set_anchors_preset(Control.PRESET_FULL_RECT)

	_backdrop.color = Color(0, 0, 0, 0.32)
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_backdrop)

	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.custom_minimum_size = Vector2(560, 360)
	_panel.position.y = 32
	add_child(_panel)

	var root := VBoxContainer.new()
	_panel.add_child(root)

	_search.placeholder_text = "Type a command..."
	_search.text_changed.connect(_apply_filter)
	_search.text_submitted.connect(func(_text: String) -> void: _select_current())
	root.add_child(_search)

	_list.size_flags_vertical = SIZE_EXPAND_FILL
	_list.item_activated.connect(_on_item_activated)
	root.add_child(_list)

	_refresh_layout()

func _refresh_layout() -> void:
	_panel.custom_minimum_size.x = 320 if is_mobile_layout else 560

func set_commands(commands: Array[Dictionary]) -> void:
	_commands = commands
	_apply_filter("")

func open_palette() -> void:
	visible = true
	_search.grab_focus()

func close_palette() -> void:
	visible = false

func _apply_filter(term: String) -> void:
	_list.clear()
	var lowered := term.strip_edges().to_lower()
	for command in _commands:
		var name := str(command.get("name", "Unnamed"))
		if lowered.is_empty() or lowered in name.to_lower():
			_list.add_item(name)
			_list.set_item_metadata(_list.get_item_count() - 1, str(command.get("id", name)))

func _on_item_activated(index: int) -> void:
	if index >= 0 and index < _list.get_item_count():
		emit_signal("command_chosen", _list.get_item_metadata(index))
		close_palette()

func _select_current() -> void:
	if _list.get_item_count() > 0:
		_on_item_activated(0)
