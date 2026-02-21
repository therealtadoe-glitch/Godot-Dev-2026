extends AdaptiveUIComponent
class_name AdaptiveAlert

signal confirmed
signal cancelled

var _backdrop := ColorRect.new()
var _panel := PanelContainer.new()
var _title := Label.new()
var _body := RichTextLabel.new()
var _ok := Button.new()
var _cancel := Button.new()

func _build_ui() -> void:
	visible = false
	z_index = 120

	_backdrop.color = Color(0, 0, 0, 0.45)
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_backdrop)

	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(380, 140)
	add_child(_panel)

	var content := VBoxContainer.new()
	_panel.add_child(content)

	_title.text = "Alert"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_title)

	_body.fit_content = true
	_body.scroll_active = false
	_body.bbcode_enabled = false
	_body.text = "Message"
	content.add_child(_body)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(actions)

	_cancel.text = "Cancel"
	_cancel.pressed.connect(func() -> void:
		hide_alert()
		emit_signal("cancelled")
	)
	actions.add_child(_cancel)

	_ok.text = "Confirm"
	_ok.pressed.connect(func() -> void:
		hide_alert()
		emit_signal("confirmed")
	)
	actions.add_child(_ok)

	_refresh_layout()

func _refresh_layout() -> void:
	var margin := get_adaptive_padding()
	for node in [_panel.get_child(0)]:
		if node is VBoxContainer:
			node.add_theme_constant_override("separation", margin)
	_panel.position = Vector2(-_panel.custom_minimum_size.x / 2.0, -_panel.custom_minimum_size.y / 2.0)
	_panel.custom_minimum_size.x = 300 if is_mobile_layout else 380

func show_alert(title: String, message: String, confirm_text := "Confirm", cancel_text := "Cancel", show_cancel := true) -> void:
	_title.text = title
	_body.text = message
	_ok.text = confirm_text
	_cancel.text = cancel_text
	_cancel.visible = show_cancel
	visible = true

func hide_alert() -> void:
	visible = false
