extends Node
class_name SupabaseClient

signal request_completed(method: String, path: String, status_code: int)

const JSON_HEADERS := ["Content-Type: application/json"]

func _build_headers(include_auth: bool = true, extra: Array = []) -> PackedStringArray:
	var headers: PackedStringArray = [
		"apikey: %s" % AppConfig.SUPABASE_ANON_KEY,
		"Content-Type: application/json"
	]
	if include_auth and not AppState.access_token.is_empty():
		headers.append("Authorization: Bearer %s" % AppState.access_token)
	for h in extra:
		headers.append(str(h))
	return headers

func _request(method: HTTPClient.Method, path: String, body: Variant = null, include_auth: bool = true, query: String = "") -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)
	var url := "%s%s%s" % [AppConfig.SUPABASE_URL, path, query]
	var payload := ""
	if body != null:
		payload = JSON.stringify(body)

	var err := http.request(url, _build_headers(include_auth), method, payload)
	if err != OK:
		http.queue_free()
		return {"ok": false, "error": "HTTP request start failed", "code": err}

	var result := await http.request_completed
	http.queue_free()

	var status_code: int = result[1]
	var raw: PackedByteArray = result[3]
	var text := raw.get_string_from_utf8()
	var parsed: Variant = text.is_empty() ? {} : JSON.parse_string(text)
	var ok := status_code >= 200 and status_code < 300
	request_completed.emit(HTTPClient.Method.keys()[method], path, status_code)

	return {
		"ok": ok,
		"status": status_code,
		"data": parsed,
		"raw": text
	}

func auth_sign_in(email: String, password: String) -> Dictionary:
	var path := "/auth/v1/token?grant_type=password"
	var body := {"email": email, "password": password}
	return await _request(HTTPClient.METHOD_POST, path, body, false)

func auth_refresh(refresh_token: String) -> Dictionary:
	var path := "/auth/v1/token?grant_type=refresh_token"
	var body := {"refresh_token": refresh_token}
	return await _request(HTTPClient.METHOD_POST, path, body, false)

func rest_select(table: String, query: String) -> Dictionary:
	return await _request(HTTPClient.METHOD_GET, "/rest/v1/%s" % table, null, true, "?%s" % query)

func rest_insert(table: String, records: Array) -> Dictionary:
	return await _request(
		HTTPClient.METHOD_POST,
		"/rest/v1/%s" % table,
		records,
		true,
		"",
	)

func rest_update(table: String, query: String, updates: Dictionary) -> Dictionary:
	return await _request(
		HTTPClient.METHOD_PATCH,
		"/rest/v1/%s" % table,
		updates,
		true,
		"?%s" % query,
	)
