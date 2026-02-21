extends Control
class_name AdaptiveUIComponent

## Base class for all modular UI controls in this package.
## - Gives responsive helpers for desktop/mobile.
## - Enforces self-building UI through _build_ui().

@export_category("Adaptive")
@export var mobile_breakpoint_px: float = 860.0
@export var desktop_padding: int = 16
@export var mobile_padding: int = 10

var is_mobile_layout := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	is_mobile_layout = _is_mobile_viewport()
	_build_ui()
	_refresh_layout()
	if not get_viewport().size_changed.is_connected(_on_viewport_resized):
		get_viewport().size_changed.connect(_on_viewport_resized)

func _build_ui() -> void:
	## Must be implemented by subclasses.
	pass

func _refresh_layout() -> void:
	## Optional for subclasses.
	pass

func get_adaptive_padding() -> int:
	return mobile_padding if is_mobile_layout else desktop_padding

func _is_mobile_viewport() -> bool:
	return get_viewport_rect().size.x <= mobile_breakpoint_px

func _on_viewport_resized() -> void:
	var now_mobile := _is_mobile_viewport()
	if now_mobile != is_mobile_layout:
		is_mobile_layout = now_mobile
	_refresh_layout()
