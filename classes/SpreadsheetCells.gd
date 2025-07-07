class_name SpreadsheetCells extends Node

# Reference =====================================
var cell_control_size: Vector2 = Vector2(32, 32)
var cell_minimum_size: Vector2 = Vector2(38, 24)
var cell_default_size: Vector2 = Vector2(80, 24)

# Variables =====================================
var cell_focused: Vector2
var selections: Array[Vector2] = []

var columns: int
var rows: int
var data: SpreadsheetData

var display_font: Font
var display_font_size: float

var cache_rows: Array = []
var cache_columns: Array = []
var cache_size: Vector2 = Vector2.ZERO

# Process =======================================
func _init(data: SpreadsheetData, columns: int, rows: int) -> void:
	set("columns", columns)
	set("rows", rows)
	set("data", data)

func set_font(font: Font, size: float) -> void:
	display_font = font
	display_font_size = size

func cache():
	cache_columns = []
	cache_rows = []
	cache_size = cell_control_size
	cache_columns.resize(columns)
	cache_rows.resize(rows)
	cache_rows.fill(0)
	
	var width: float = 0
	var cell_size: Vector2
	for x in range(columns):
		width = 0
		for y in range(rows):
			cell_size = get_cell_size(x, y)
			width = max(width, cell_size.x)
			cache_rows[y] = max(cache_rows[y], cell_size.y)
		cache_columns[x] = width
		cache_size.x += width
	
	for height in cache_rows:
		cache_size.y += height

# Selection =====================================
func is_cell_selected(cell: Vector2) -> bool: return selections.has(cell)
func is_cell_focused(cell: Vector2) -> bool: return cell_focused == cell

func select_all() -> void: select_range(Rect2(Vector2.ZERO, Vector2(columns, rows)))
func select_range(rect: Rect2) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			select(Vector2(x, y))

func deselect_all() -> void: selections = []
func select(cell: Vector2) -> void: if not selections.has(cell): selections.append(cell)
func focus(cell: Vector2) -> void: cell_focused = cell.clamp(Vector2.ZERO, Vector2(columns-1, rows-1))
func navigate(ox: int, oy: int) -> void:
	var offset = Vector2(ox, oy)
	for selection in selections:
		if selection + offset < Vector2.ZERO: return
	
	# Navigate
	var start = cell_focused
	focus(cell_focused + offset)
	var difference = cell_focused - start
	for i in range(len(selections)): selections[i] = selections[i] + difference

# Cell data =====================================
func get_value() -> Variant:
	return data.get_value(cell_focused.x, cell_focused.y)

func get_value_string() -> Variant:
	var value = get_value()
	return str(value) if value else ""

func set_value(value: Variant) -> void:
	data.set_value(cell_focused.x, cell_focused.y, value)
	for cell in selections:
		data.set_value(cell.x, cell.y, value)

# Calculations ==================================
func get_cell_size(x: int, y: int) -> Vector2:
	var value = data.get_value(x, y)
	if value:
		var size = display_font.get_string_size(str(value), 0, -1, display_font_size) + Vector2(16, 0)
		return cell_minimum_size.max(size)
	return cell_default_size

func get_cell_at_position(at_position: Vector2) -> Vector2:
	var size = cell_control_size
	var cell = Vector2(columns, rows)
	for x in range(columns):
		size.x += cache_columns[x]
		cell.x = x
		if size.x > at_position.x: break
	for y in range(rows):
		size.y += cache_rows[y]
		cell.y = y
		if size.y > at_position.y: break
	return cell

func get_cell_position(cell: Vector2) -> Vector2:
	var position = cell_control_size
	for x in range(cell.x): position.x += cache_columns[x]
	for y in range(cell.y): position.y += cache_columns[y]
	return position
