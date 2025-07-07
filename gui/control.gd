@tool class_name SpreadsheetEditorControl extends Control

# Variables =====================================
var menu_file: MenuButton
var menu_edit: MenuButton
var file_list: ItemList
var spreadsheet: Spreadsheet

# Process =======================================
func _enter_tree() -> void:
	menu_file = $VBoxContainer/HBoxContainer/File
	menu_edit = $VBoxContainer/HBoxContainer/Edit
	file_list = $VBoxContainer/HSplitContainer/VBoxContainer/FileList/ItemList
	spreadsheet = $VBoxContainer/HSplitContainer/ScrollContainer/Spreadsheet
	populate_menus()

# Methods =======================================
func edit(object: SpreadsheetData):
	spreadsheet.set_data(object)

func populate_menus() -> void:
	var file_popup: PopupMenu = menu_file.get_popup()
	var edit_popup: PopupMenu = menu_edit.get_popup()
	file_popup.clear()
	edit_popup.clear()
	
	# File ======================================
	file_popup.add_item("Open File", 0)
	file_popup.add_item("Open Folder", 1)
	file_popup.add_separator("", 2)
	file_popup.add_item("Save", 3)
	file_popup.add_item("Save as...", 4)
	file_popup.add_item("Save all", 5)
	file_popup.id_pressed.connect(func(id: int):
		match id:
			0: pass
			1: pass
			3: pass
			4: pass
			5: pass
	)
	
	# Edit ======================================
	edit_popup.add_item("Cut cell(s)", 0)
	edit_popup.add_item("Copy cell(s)", 1)
	edit_popup.add_item("Paste cell(s)", 2)
	edit_popup.id_pressed.connect(func(id: int):
		match id:
			0: pass
			1: pass
			2: pass
	)

# Signals =======================================
