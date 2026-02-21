extends AdaptiveUIComponent
class_name BottomSheet

signal opened
signal closed

@export var collapsed_height: float = 66.0
@export var expanded_height_ratio: float = 0.72

var _sheet := PanelContainer.new()
var _handle := ColorRect.new()
var _content := MarginContainer.new()
var _expanded := false

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	_sheet.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_sheet.offset_top = -collapsed_height
	_sheet.offset_bottom = 0
	add_child(_sheet)

	var root := VBoxContainer.new()
	_sheet.add_child(root)

	_handle.color = Color(0.7, 0.7, 0.7, 0.9)
	_handle.custom_minimum_size = Vector2(48, 6)
	_handle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_handle)

	_content.size_flags_vertical = SIZE_EXPAND_FILL
	root.add_child(_content)

	_sheet.gui_input.connect(_handle_sheet_input)
	_refresh_layout()

func _refresh_layout() -> void:
	var margin := get_adaptive_padding()
	_content.add_theme_constant_override("margin_left", margin)
	_content.add_theme_constant_override("margin_right", margin)
	_content.add_theme_constant_override("margin_top", margin)
	_content.add_theme_constant_override("margin_bottom", margin)

func set_content(control: Control) -> void:
	for child in _content.get_children():
		child.queue_free()
	_content.add_child(control)

func expand() -> void:
	var target_height := size.y * expanded_height_ratio
	var tween := create_tween()
	tween.tween_property(_sheet, "offset_top", -target_height, 0.22)
	_expanded = true
	emit_signal("opened")

func collapse() -> void:
	var tween := create_tween()
	tween.tween_property(_sheet, "offset_top", -collapsed_height, 0.2)
	_expanded = false
	emit_signal("closed")

func toggle() -> void:
	if _expanded:
		collapse()
	else:
		expand()

func _handle_sheet_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle()
