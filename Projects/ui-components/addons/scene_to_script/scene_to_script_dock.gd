@tool
extends VBoxContainer

const PLUGIN_VERSION := "1.0.0"
const INDENT := "\t"

enum InstantiationStyle {
	PACKED_SCENE,
	MANUAL,
}

var _scene_path_edit: LineEdit
var _output_path_edit: LineEdit
var _log_output: TextEdit

var _include_exported_check: CheckBox
var _non_default_check: CheckBox
var _include_groups_check: CheckBox
var _include_signals_check: CheckBox
var _include_resources_check: CheckBox
var _include_owner_check: CheckBox
var _instantiation_style_option: OptionButton

var _scene_dialog: FileDialog
var _output_dialog: FileDialog

var _var_map: Dictionary = {}
var _resource_var_map: Dictionary = {}
var _resource_counter := 0
var _node_counter := 0

func _ready() -> void:
	name = "Scene→Script"
	size_flags_vertical = SIZE_EXPAND_FILL
	_build_ui()

func _build_ui() -> void:
	var title := Label.new()
	title.text = "Scene to Script Converter"
	add_child(title)

	var scene_row := HBoxContainer.new()
	add_child(scene_row)
	var scene_label := Label.new()
	scene_label.text = "Scene input (.tscn):"
	scene_label.custom_minimum_size.x = 160
	scene_row.add_child(scene_label)
	_scene_path_edit = LineEdit.new()
	_scene_path_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_scene_path_edit.text_changed.connect(_on_scene_path_changed)
	scene_row.add_child(_scene_path_edit)
	var scene_browse := Button.new()
	scene_browse.text = "Browse"
	scene_browse.pressed.connect(_on_scene_browse_pressed)
	scene_row.add_child(scene_browse)

	var output_row := HBoxContainer.new()
	add_child(output_row)
	var output_label := Label.new()
	output_label.text = "Output script path:"
	output_label.custom_minimum_size.x = 160
	output_row.add_child(output_label)
	_output_path_edit = LineEdit.new()
	_output_path_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	output_row.add_child(_output_path_edit)
	var output_browse := Button.new()
	output_browse.text = "Browse"
	output_browse.pressed.connect(_on_output_browse_pressed)
	output_row.add_child(output_browse)

	add_child(HSeparator.new())

	_include_exported_check = _make_check("Include exported properties", true)
	_non_default_check = _make_check("Include non-default properties only", true)
	_include_groups_check = _make_check("Include node groups", true)
	_include_signals_check = _make_check("Include signals (connections) when possible", true)
	_include_resources_check = _make_check("Include resources", true)
	_include_owner_check = _make_check("Include children order and owner where applicable", true)

	var style_row := HBoxContainer.new()
	add_child(style_row)
	var style_label := Label.new()
	style_label.text = "Instantiation style:"
	style_label.custom_minimum_size.x = 160
	style_row.add_child(style_label)
	_instantiation_style_option = OptionButton.new()
	_instantiation_style_option.add_item("PackedScene.instantiate()", InstantiationStyle.PACKED_SCENE)
	_instantiation_style_option.add_item("Manual Node.new()", InstantiationStyle.MANUAL)
	style_row.add_child(_instantiation_style_option)

	var convert_button := Button.new()
	convert_button.text = "Convert"
	convert_button.pressed.connect(_on_convert_pressed)
	add_child(convert_button)

	_log_output = TextEdit.new()
	_log_output.editable = false
	_log_output.size_flags_vertical = SIZE_EXPAND_FILL
	_log_output.custom_minimum_size.y = 220
	add_child(_log_output)

	_scene_dialog = FileDialog.new()
	_scene_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_scene_dialog.access = FileDialog.ACCESS_RESOURCES
	_scene_dialog.filters = PackedStringArray(["*.tscn ; Godot Scene"])
	_scene_dialog.file_selected.connect(_on_scene_selected)
	add_child(_scene_dialog)

	_output_dialog = FileDialog.new()
	_output_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_output_dialog.access = FileDialog.ACCESS_RESOURCES
	_output_dialog.filters = PackedStringArray(["*.gd ; GDScript"])
	_output_dialog.file_selected.connect(_on_output_selected)
	add_child(_output_dialog)

func _make_check(label_text: String, enabled: bool) -> CheckBox:
	var check := CheckBox.new()
	check.text = label_text
	check.button_pressed = enabled
	add_child(check)
	return check

func _on_scene_browse_pressed() -> void:
	_scene_dialog.popup_centered_ratio(0.7)

func _on_output_browse_pressed() -> void:
	_output_dialog.current_path = _output_path_edit.text
	_output_dialog.popup_centered_ratio(0.7)

func _on_scene_selected(path: String) -> void:
	_scene_path_edit.text = path

func _on_output_selected(path: String) -> void:
	_output_path_edit.text = path

func _on_scene_path_changed(path: String) -> void:
	if path.get_extension().to_lower() != "tscn":
		return
	if _output_path_edit.text.strip_edges() != "":
		return
	var base := path.get_basename()
	_output_path_edit.text = "%s_generated.gd" % base

func _on_convert_pressed() -> void:
	var scene_path := _scene_path_edit.text.strip_edges()
	if scene_path == "" or scene_path.get_extension().to_lower() != "tscn":
		_log("ERROR: Please select a valid .tscn scene path.")
		return

	var output_path := _output_path_edit.text.strip_edges()
	if output_path == "":
		output_path = "%s_generated.gd" % scene_path.get_basename()
		_output_path_edit.text = output_path
	if output_path.get_extension().to_lower() != "gd":
		_log("ERROR: Output path must end in .gd")
		return

	var packed := ResourceLoader.load(scene_path)
	if packed == null or not (packed is PackedScene):
		_log("ERROR: Could not load PackedScene at %s" % scene_path)
		return

	var root := (packed as PackedScene).instantiate()
	if root == null:
		_log("ERROR: Scene instantiate() failed.")
		return

	reset_generation_state()
	var options := {
		"include_exported": _include_exported_check.button_pressed,
		"non_default_only": _non_default_check.button_pressed,
		"include_groups": _include_groups_check.button_pressed,
		"include_signals": _include_signals_check.button_pressed,
		"include_resources": _include_resources_check.button_pressed,
		"include_owner": _include_owner_check.button_pressed,
		"instantiation_style": _instantiation_style_option.get_selected_id(),
	}

	var script_text := _generate_script(scene_path, root, options)
	var err := _write_text_file(output_path, script_text)
	if err != OK:
		_log("ERROR: Failed writing output file (%s), err=%d" % [output_path, err])
	else:
		_log("Done. Generated script at %s" % output_path)
		EditorInterface.get_resource_filesystem().scan()

	root.queue_free()

func reset_generation_state() -> void:
	_var_map.clear()
	_resource_var_map.clear()
	_resource_counter = 0
	_node_counter = 0
	_log_output.clear()

func _generate_script(scene_path: String, root: Node, options: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Auto-generated by Scene To Script Converter")
	lines.append("# Original scene: %s" % scene_path)
	lines.append("# Generated at: %s" % Time.get_datetime_string_from_system())
	lines.append("# Plugin version: %s" % PLUGIN_VERSION)
	lines.append("# WARNING: This script is best-effort and may not reproduce runtime-only state, callables, internal handles, editor-only metadata, or unsupported resources/signals exactly.")
	lines.append("")
	lines.append("extends RefCounted")
	lines.append("")
	lines.append("static func build() -> Node:")

	var body: Array[String] = []
	body.append("var root: Node")
	if int(options["instantiation_style"]) == InstantiationStyle.PACKED_SCENE:
		body.append("var packed := load(\"%s\")" % scene_path)
		body.append("if packed is PackedScene:")
		body.append(INDENT + "root = (packed as PackedScene).instantiate()")
		body.append("else:")
		body.append(INDENT + "root = _create_%s()" % _safe_identifier(_class_for_node(root).to_lower()))
		_log("Using PackedScene.instantiate() strategy for root where possible.")
	else:
		body.append("root = _create_%s()" % _safe_identifier(_class_for_node(root).to_lower()))
		_log("Using Manual Node.new() strategy.")
	body.append("if root == null:")
	body.append(INDENT + "return null")

	var factory_lines := _collect_factories(root)
	var build_lines := _collect_build_lines(root, options)
	var helper_lines := _collect_helpers()

	for line in build_lines:
		body.append(line)
	body.append("return root")

	for line in body:
		lines.append(INDENT + line)

	lines.append("")
	for line in factory_lines:
		lines.append(line)

	lines.append("")
	for line in helper_lines:
		lines.append(line)

	return "\n".join(lines) + "\n"

func _collect_factories(root: Node) -> Array[String]:
	var lines: Array[String] = []
	var classes_done: Dictionary = {}
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node := stack.pop_back()
		var class_name := _class_for_node(node)
		var key := _safe_identifier(class_name.to_lower())
		if not classes_done.has(key):
			classes_done[key] = true
			lines.append("static func _create_%s() -> Node:" % key)
			lines.append(INDENT + "var n := %s.new()" % class_name)
			lines.append(INDENT + "return n")
			lines.append("")
		for child in node.get_children():
			if child is Node:
				stack.append(child)
	return lines

func _collect_build_lines(root: Node, options: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	_assign_var(root, "root")
	lines.append("root.name = %s" % var_to_str(root.name))

	_traverse_and_emit(root, null, lines, options)
	if bool(options["include_signals"]):
		_emit_signals(root, lines)
	return lines

func _traverse_and_emit(node: Node, parent: Node, lines: Array[String], options: Dictionary) -> void:
	var node_var := _var_for(node)
	if parent != null:
		var class_name := _class_for_node(node)
		var factory_name := "_create_%s" % _safe_identifier(class_name.to_lower())
		var creation := "var %s: Node = %s()" % [node_var, factory_name]
		if int(options["instantiation_style"]) == InstantiationStyle.PACKED_SCENE and node.scene_file_path != "":
			creation = "var %s: Node = load(\"%s\").instantiate()" % [node_var, node.scene_file_path]
		lines.append(creation)
		lines.append("%s.name = %s" % [node_var, var_to_str(node.name)])
		lines.append("%s.add_child(%s)" % [_var_for(parent), node_var])

		if bool(options["include_owner"]) and node.owner != null:
			if node == node.owner:
				lines.append("%s.owner = %s" % [node_var, node_var])
			elif _var_map.has(node.owner):
				lines.append("%s.owner = %s" % [node_var, _var_for(node.owner)])

	_emit_properties(node, lines, options)
	if bool(options["include_groups"]):
		_emit_groups(node, lines)

	for child in node.get_children():
		if child is Node:
			_traverse_and_emit(child, node, lines, options)

func _emit_properties(node: Node, lines: Array[String], options: Dictionary) -> void:
	var node_var := _var_for(node)
	var defaults := _default_values_for(node)
	for prop in node.get_property_list():
		if not (prop is Dictionary):
			continue
		var p := prop as Dictionary
		var pname := String(p.get("name", ""))
		if not _should_include_property(node, p, options):
			continue
		var value = node.get(pname)
		if bool(options["non_default_only"]) and defaults.has(pname):
			if defaults[pname] == value:
				continue
		var serialized := _serialize_variant(value, lines, options, 0)
		if serialized == "":
			_log("Skipped unsupported property %s on %s" % [pname, node.get_path()])
			continue
		lines.append("%s.%s = %s" % [node_var, pname, serialized])

func _should_include_property(node: Node, prop: Dictionary, options: Dictionary) -> bool:
	var pname := String(prop.get("name", ""))
	if pname == "" or pname == "name" or pname == "owner" or pname == "script" or pname == "scene_file_path":
		return false
	if pname.begins_with("_"):
		return false
	var usage := int(prop.get("usage", 0))
	if (usage & PROPERTY_USAGE_STORAGE) == 0:
		return false
	if not bool(options["include_exported"]) and (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
		return false
	if pname in [
		"multiplayer", "physics_interpolation_mode", "process_physics_priority", "process_priority",
		"process_mode", "tree_exiting", "tree_entered", "tree_exited"
	]:
		return false
	return true

func _emit_groups(node: Node, lines: Array[String]) -> void:
	var groups := node.get_groups()
	var node_var := _var_for(node)
	for group_name in groups:
		if String(group_name).begins_with("_"):
			continue
		lines.append("%s.add_to_group(%s)" % [node_var, var_to_str(group_name)])

func _emit_signals(root: Node, lines: Array[String]) -> void:
	var all_nodes: Array[Node] = []
	_collect_nodes(root, all_nodes)
	for node in all_nodes:
		for signal_info in node.get_signal_list():
			if not (signal_info is Dictionary):
				continue
			var signal_name := String(signal_info.get("name", ""))
			for conn in node.get_signal_connection_list(signal_name):
				if not (conn is Dictionary):
					continue
				var callable: Callable = conn.get("callable", Callable())
				if not callable.is_valid():
					continue
				var target := callable.get_object()
				if not (target is Node):
					_log("Skipped signal %s on %s (non-node callable target)." % [signal_name, node.get_path()])
					continue
				if not _var_map.has(target):
					_log("Skipped signal %s on %s (target not in scene tree)." % [signal_name, node.get_path()])
					continue
				var method_name := callable.get_method()
				if method_name == "":
					_log("Skipped signal %s on %s (empty method)." % [signal_name, node.get_path()])
					continue
				lines.append("%s.connect(%s, Callable(%s, %s))" % [
					_var_for(node), var_to_str(signal_name), _var_for(target), var_to_str(method_name)
				])

func _collect_nodes(node: Node, out: Array[Node]) -> void:
	out.append(node)
	for child in node.get_children():
		if child is Node:
			_collect_nodes(child, out)

func _serialize_variant(value, lines: Array[String], options: Dictionary, depth: int) -> String:
	if value == null:
		return "null"
	if value is bool or value is int or value is float or value is String or value is StringName:
		return var_to_str(value)
	if value is Vector2 or value is Vector3 or value is Vector4 or value is Color:
		return var_to_str(value)
	if value is Rect2 or value is Rect2i or value is Transform2D or value is Transform3D:
		return var_to_str(value)
	if value is Basis or value is Quaternion or value is Plane or value is AABB:
		return var_to_str(value)
	if value is NodePath:
		return "NodePath(%s)" % var_to_str(String(value))
	if value is RID or value is Callable or value is Signal:
		return ""
	if value is Array:
		var result: Array[String] = []
		for item in value:
			var s := _serialize_variant(item, lines, options, depth + 1)
			if s == "":
				return ""
			result.append(s)
		return "[%s]" % ", ".join(result)
	if value is Dictionary:
		var pieces: Array[String] = []
		for key in value.keys():
			var k := _serialize_variant(key, lines, options, depth + 1)
			var v := _serialize_variant(value[key], lines, options, depth + 1)
			if k == "" or v == "":
				return ""
			pieces.append("%s: %s" % [k, v])
		return "{%s}" % ", ".join(pieces)
	if value is Resource:
		if not bool(options["include_resources"]):
			return ""
		return _serialize_resource(value, lines, options)
	if value is Object:
		return ""
	return var_to_str(value)

func _serialize_resource(resource: Resource, lines: Array[String], options: Dictionary) -> String:
	if resource == null:
		return "null"
	if _resource_var_map.has(resource):
		return _resource_var_map[resource]
	if resource.resource_path != "" and resource.resource_path.begins_with("res://"):
		return "load(%s)" % var_to_str(resource.resource_path)

	var var_name := "res_%d" % _resource_counter
	_resource_counter += 1
	_resource_var_map[resource] = var_name
	lines.append("var %s := %s.new()" % [var_name, resource.get_class()])

	for prop in resource.get_property_list():
		if not (prop is Dictionary):
			continue
		var p := prop as Dictionary
		var usage := int(p.get("usage", 0))
		if (usage & PROPERTY_USAGE_STORAGE) == 0:
			continue
		var pname := String(p.get("name", ""))
		if pname == "resource_path" or pname == "resource_name" or pname.begins_with("_"):
			continue
		var serialized := _serialize_variant(resource.get(pname), lines, options, 1)
		if serialized == "":
			continue
		lines.append("%s.%s = %s" % [var_name, pname, serialized])

	return var_name

func _default_values_for(node: Node) -> Dictionary:
	var defaults := {}
	var class_name := _class_for_node(node)
	var default_obj = ClassDB.instantiate(class_name)
	if default_obj == null:
		return defaults
	for prop in default_obj.get_property_list():
		if not (prop is Dictionary):
			continue
		var p := prop as Dictionary
		var usage := int(p.get("usage", 0))
		if (usage & PROPERTY_USAGE_STORAGE) == 0:
			continue
		var pname := String(p.get("name", ""))
		defaults[pname] = default_obj.get(pname)
	if default_obj is Object:
		(default_obj as Object).free()
	return defaults

func _class_for_node(node: Node) -> String:
	var script := node.get_script()
	if script != null and script is Script:
		var global_name := (script as Script).get_global_name()
		if global_name != "":
			return global_name
	return node.get_class()

func _assign_var(node: Node, var_name: String) -> void:
	_var_map[node] = var_name

func _var_for(node: Node) -> String:
	if _var_map.has(node):
		return _var_map[node]
	var clean := _safe_identifier(node.name.to_lower())
	var var_name := "n_%s_%d" % [clean, _node_counter]
	_node_counter += 1
	_var_map[node] = var_name
	return var_name

func _safe_identifier(value: String) -> String:
	var s := value.strip_edges()
	if s == "":
		return "node"
	var out := ""
	for i in s.length():
		var ch := s[i]
		var code := ch.unicode_at(0)
		var is_valid := (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or ch == "_"
		out += ch if is_valid else "_"
	var first := out.unicode_at(0)
	if first >= 48 and first <= 57:
		out = "n_" + out
	return out

func _collect_helpers() -> Array[String]:
	return [
		"static func _log_warning(message: String) -> void:",
		INDENT + "push_warning(message)",
	]

func _write_text_file(path: String, text: String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	return OK

func _log(message: String) -> void:
	if _log_output.text != "":
		_log_output.text += "\n"
	_log_output.text += message
