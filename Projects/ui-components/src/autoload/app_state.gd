extends Node
class_name AppState

signal session_changed(is_authenticated: bool)
signal role_changed(role: String)

var access_token := ""
var refresh_token := ""
var user_id := ""
var email := ""
var full_name := ""
var role := ""

func is_authenticated() -> bool:
	return not access_token.is_empty()

func set_session(payload: Dictionary) -> void:
	access_token = payload.get("access_token", "")
	refresh_token = payload.get("refresh_token", "")
	user_id = payload.get("user_id", "")
	email = payload.get("email", "")
	full_name = payload.get("full_name", "")
	role = payload.get("role", "")
	session_changed.emit(is_authenticated())
	role_changed.emit(role)

func clear_session() -> void:
	access_token = ""
	refresh_token = ""
	user_id = ""
	email = ""
	full_name = ""
	role = ""
	session_changed.emit(false)
	role_changed.emit("")

func has_role(target_role: String) -> bool:
	return role == target_role

func has_any_role(roles: PackedStringArray) -> bool:
	return role in roles
