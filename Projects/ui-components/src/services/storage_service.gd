extends Node
class_name StorageService

func upload_binary(bucket: String, object_path: String, data: PackedByteArray, mime_type: String = "image/jpeg") -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)
	var url := "%s/storage/v1/object/%s/%s" % [AppConfig.SUPABASE_URL, bucket, object_path]
	var headers := PackedStringArray([
		"apikey: %s" % AppConfig.SUPABASE_ANON_KEY,
		"Authorization: Bearer %s" % AppState.access_token,
		"Content-Type: %s" % mime_type,
		"x-upsert: true"
	])
	var err := http.request_raw(url, headers, HTTPClient.METHOD_POST, data)
	if err != OK:
		http.queue_free()
		return {"ok": false, "error": "Upload request failed", "code": err}
	var result := await http.request_completed
	http.queue_free()
	var status_code: int = result[1]
	var ok := status_code >= 200 and status_code < 300
	return {"ok": ok, "status": status_code}
