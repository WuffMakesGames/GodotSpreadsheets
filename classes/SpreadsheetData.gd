class_name SpreadsheetData extends Resource
@export_storage var importer_is_spreadsheet = true
@export var data: Array[Array] = []

# Import/export =================================
func load_file(path: StringName) -> void:
	match path.get_extension():
		"csv": data = CSV.parse_string(FileAccess.get_file_as_string(path))

func save_file(path: StringName) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	match path.get_extension():
		"csv": file.store_string(CSV.get_string(data))

# Values ========================================
func set_value(x: int, y: int, value: Variant) -> void:
	for i in range(len(data), y+1): data.append([])
	for i in range(len(data[y]), x+1): data[y].append("")
	data[y][x] = value

func get_value(x: int, y: int, default: Variant = null) -> Variant:
	if len(data) <= y: return default
	if len(data[y]) <= x: return default 
	return data[y][x]

# Cells =========================================
func get_rows() -> int: return len(data)
func get_columns() -> int:
	var columns: int = 0
	for row in data:
		columns = max(columns, len(row))
	return columns
