extends AdaptiveUIComponent
class_name ToastStack

@export var default_duration: float = 2.0
@export var max_toasts: int = 4

var _stack := VBoxContainer.new()

func _build_ui() -> void:
	name = "ToastStack"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	position = Vector2(-12, 12)
	custom_minimum_size = Vector2(320, 10)

	_stack.alignment = BoxContainer.ALIGNMENT_END
	_stack.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(_stack)

func _refresh_layout() -> void:
	_stack.add_theme_constant_override("separation", get_adaptive_padding() / 2)

func push_toast(message: String, duration := -1.0) -> void:
	if _stack.get_child_count() >= max_toasts:
		_stack.get_child(0).queue_free()

	var toast := PanelContainer.new()
	toast.size_flags_horizontal = SIZE_EXPAND_FILL
	toast.modulate = Color(1, 1, 1, 0)

	var label := Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	toast.add_child(label)
	_stack.add_child(toast)

	var tween := create_tween()
	tween.tween_property(toast, "modulate:a", 1.0, 0.2)

	var timer := get_tree().create_timer(default_duration if duration < 0 else duration)
	timer.timeout.connect(func() -> void:
		var fade := create_tween()
		fade.tween_property(toast, "modulate:a", 0.0, 0.25)
		fade.finished.connect(func() -> void: toast.queue_free())
	)
