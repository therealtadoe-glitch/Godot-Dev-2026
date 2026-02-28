extends Node
class_name AuthService

signal login_succeeded()
signal login_failed(message: String)
signal logout_completed()

func login_with_email(email: String, password: String) -> void:
	var auth_result := await SupabaseClient.auth_sign_in(email, password)
	if not auth_result.ok:
		login_failed.emit("Login failed")
		return

	var auth_data: Dictionary = auth_result.data
	var user: Dictionary = auth_data.get("user", {})
	var user_id := user.get("id", "")

	var profile_result := await SupabaseClient.rest_select("profiles", "select=full_name,role,email&user_id=eq.%s" % user_id)
	if not profile_result.ok:
		login_failed.emit("Unable to load profile")
		return

	var profile := {}
	if profile_result.data is Array and profile_result.data.size() > 0:
		profile = profile_result.data[0]

	AppState.set_session({
		"access_token": auth_data.get("access_token", ""),
		"refresh_token": auth_data.get("refresh_token", ""),
		"user_id": user_id,
		"email": profile.get("email", email),
		"full_name": profile.get("full_name", ""),
		"role": profile.get("role", "EMPLOYEE")
	})
	login_succeeded.emit()

func refresh_session() -> bool:
	if AppState.refresh_token.is_empty():
		return false
	var refresh_result := await SupabaseClient.auth_refresh(AppState.refresh_token)
	if not refresh_result.ok:
		AppState.clear_session()
		return false
	var payload: Dictionary = refresh_result.data
	AppState.access_token = payload.get("access_token", "")
	AppState.refresh_token = payload.get("refresh_token", "")
	AppState.session_changed.emit(AppState.is_authenticated())
	return true

func logout() -> void:
	AppState.clear_session()
	logout_completed.emit()
