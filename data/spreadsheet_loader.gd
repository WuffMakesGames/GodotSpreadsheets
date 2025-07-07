@tool class_name SpreadsheetFormatLoader extends ResourceFormatLoader

#region Editor API
func _get_recognized_extensions() -> PackedStringArray: return PackedStringArray(["csv"])
func _recognize(resource: Resource) -> bool: return resource is SpreadsheetData
func _handles_type(type: StringName) -> bool: return type == "Resource"

func _get_resource_script_class(path: String) -> String:
	if path.get_extension() == "csv": return "SpreadsheetData"
	return ""
func _get_resource_type(path: String) -> String:
	if path.get_extension() == "csv": return "Resource"
	return ""
#endregion

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var spreadsheet_data := SpreadsheetData.new()
	spreadsheet_data.load_file(original_path)
	return spreadsheet_data
