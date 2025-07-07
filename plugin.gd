@tool extends EditorPlugin

# Variables =====================================
var control: SpreadsheetEditorControl
var control_scene: PackedScene = preload("res://addons/csv-editor/gui/control.tscn")

var loader := SpreadsheetFormatLoader.new()
var saver := SpreadsheetFormatSaver.new()
var importer := ResourceImporterSpreadsheet.new()

# Plugin ========================================
func _init() -> void:
	ResourceLoader.add_resource_format_loader(loader)
	ResourceSaver.add_resource_format_saver(saver)
	add_import_plugin(importer, true)
	
func _disable_plugin() -> void:
	ResourceLoader.remove_resource_format_loader(loader)
	ResourceSaver.remove_resource_format_saver(saver)
	#remove_import_plugin(importer)
	
func _enter_tree() -> void:
	control = control_scene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(control)
	_make_visible(false)

func _exit_tree() -> void:
	if control: control.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if control: control.visible = visible

func _get_plugin_name():
	return "CSV"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Grid", "EditorIcons")

func _handles(object: Object) -> bool:
	return object.get("importer_is_spreadsheet") == true

func _edit(object: Object) -> void:
	control.edit(object)
