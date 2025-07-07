@tool class_name SpreadsheetFormatSaver extends ResourceFormatSaver

#region Editor API
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return ["csv"]

func _recognize(resource: Resource) -> bool:
	return resource is SpreadsheetData

#endregion
func _save(resource: Resource, path: String, flags: int) -> Error:
	resource.save_file(path)
	return OK
