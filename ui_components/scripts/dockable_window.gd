extends AdaptiveUIComponent
class_name DockableWindow

signal closed

@export var title: String = "Window"

var _panel := PanelContainer.new()
var _drag_handle := HBoxContainer.new()
var _title_label := Label.new()
var _body_host := MarginContainer.new()
var _close_button := Button.new()

var _dragging := false
var _drag_offset := Vector2.ZERO

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(420, 280)
	position = Vector2(64, 64)

	_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	_panel.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_panel)

	var root := VBoxContainer.new()
	_panel.add_child(root)

	_drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_drag_handle)

	_title_label.text = title
	_title_label.size_flags_horizontal = SIZE_EXPAND_FILL
	_drag_handle.add_child(_title_label)

	_close_button.text = "×"
	_close_button.custom_minimum_size = Vector2(34, 28)
	_close_button.pressed.connect(func() -> void:
		queue_free()
		emit_signal("closed")
	)
	_drag_handle.add_child(_close_button)

	_body_host.size_flags_vertical = SIZE_EXPAND_FILL
	root.add_child(_body_host)

	_drag_handle.gui_input.connect(_on_drag_gui_input)
	_refresh_layout()

func _refresh_layout() -> void:
	var margin := get_adaptive_padding()
	_body_host.add_theme_constant_override("margin_left", margin)
	_body_host.add_theme_constant_override("margin_top", margin)
	_body_host.add_theme_constant_override("margin_right", margin)
	_body_host.add_theme_constant_override("margin_bottom", margin)
	custom_minimum_size.x = 300 if is_mobile_layout else 420
	custom_minimum_size.y = 220 if is_mobile_layout else 280

func set_content(node: Control) -> void:
	for child in _body_host.get_children():
		child.queue_free()
	_body_host.add_child(node)

func _on_drag_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
