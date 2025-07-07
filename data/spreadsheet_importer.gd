@tool class_name ResourceImporterSpreadsheet extends EditorImportPlugin

#region Editor API
func _get_importer_name() -> String: return "plugin.importer.spreadsheet"
func _get_visible_name() -> String: return "Spreadsheet Data"

func _get_recognized_extensions() -> PackedStringArray: return ["csv"]
func _get_save_extension() -> String: return "res"

func _get_resource_type() -> String: return "SpreadsheetData"
func _get_priority() -> float: return 1.0

func _get_preset_count() -> int: return 1
func _get_preset_name(preset_index: int) -> String: return "Default"

func _get_import_order() -> int: return 0
func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return [{
		"name": "Delimiter",
		"default_value": 0,
		"property_hint": PROPERTY_HINT_ENUM,
		"hint_string": "Comma,Semicolon,Tab"
	}]

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool: return true
#endregion

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null: return FAILED
	
	# Import resource
	var resource = SpreadsheetData.new()
	resource.load_file(source_file)
	
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(resource, filename)
