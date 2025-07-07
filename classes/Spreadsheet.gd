@tool class_name Spreadsheet extends Control

# Export ========================================
@export var default_columns: int = 50
@export var default_rows: int = 50

@export_subgroup("Colors")
@export var COLOR_HEADER: Color = Color("#333333")
@export var COLOR_BORDER: Color = Color("#666666")
@export var COLOR_CELL: Color = Color("#222222")
@export var COLOR_SELECTION: Color = Color("#224556")

# Variables =====================================
@onready var columns = default_columns
@onready var rows = default_rows

var data: SpreadsheetData
var cells: SpreadsheetCells

var editing: bool = false
var cursor_x: int = 0

# Process =======================================
func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	
	# Default
	data = SpreadsheetData.new()
	cells = SpreadsheetCells.new(data, columns, rows)
	cells.set_font(get_theme_default_font(), 12)
	
	set_data(SpreadsheetData.new())
	add_child(cells)

func _process(delta: float) -> void:
	cells.cache()
	custom_minimum_size = cells.cache_size
	queue_redraw()

func _draw() -> void:
	if is_node_ready(): render(get_theme_default_font(), get_scroll())

func set_data(spreadsheet_data: SpreadsheetData):
	data = spreadsheet_data
	columns = max(default_columns, data.get_columns())
	rows = max(default_rows, data.get_rows())
	cells._init(data, columns, rows)

# Inputs ========================================
func _gui_input(event: InputEvent) -> void:
	# Mouse input
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			process_click(event.position, MOUSE_BUTTON_LEFT)
	# Keyboard input
	elif event is InputEventKey and event.is_pressed():
		# Save file
		if event.keycode == KEY_S and Input.is_key_pressed(KEY_CTRL):
			ResourceSaver.save(data)
		# Handle inputs
		else:
			var char = ""
			if OS.is_keycode_unicode(event.keycode): char = String.chr(event.unicode)
			if editing: keyboard_edit(cells.get_value_string(), event, char)
			else: keyboard_process(cells.get_value_string(), event, char)
			cursor_x = clamp(cursor_x, 0, len(cells.get_value_string()))
			accept_event()

func keyboard_edit(value: String, event: InputEventKey, char: String) -> void:
	if char != "":
		cells.set_value(str(value.substr(0, cursor_x), char, value.substr(cursor_x)))
		cursor_x += 1
	else:
		match event.keycode:
			KEY_BACKSPACE:
				cells.set_value(str(value.substr(0, max(0, cursor_x-1)), value.substr(cursor_x, len(value))))
				cursor_x -= 1
			KEY_DELETE:
				cells.set_value(str(value.substr(0, cursor_x), value.substr(cursor_x+1)))
			
			# Navigate
			KEY_UP: cursor_x = 0
			KEY_DOWN: cursor_x = len(value)
			KEY_LEFT: cursor_x = max(0, cursor_x-1)
			KEY_RIGHT: cursor_x = min(len(value), cursor_x+1)
			
			# Cancel editing
			KEY_ESCAPE: editing = false
			KEY_ENTER:
				editing = false
				cells.navigate(0, 1)

func keyboard_process(value: String, event: InputEventKey, char: String) -> void:
	if char != "":
		keyboard_edit("", event, char)
		editing = true
	else:
		match event.keycode:
			KEY_DELETE, KEY_BACKSPACE: cells.set_value("")
			KEY_UP: cells.navigate(0, -1)
			KEY_DOWN, KEY_ENTER: cells.navigate(0, 1)
			KEY_LEFT: cells.navigate(-1, 0)
			KEY_RIGHT: cells.navigate(1, 0)
			KEY_ESCAPE: cells.deselect_all()

func process_click(at_position: Vector2, button_index: int) -> void:
	var header_position = at_position - get_scroll()
	var cell = cells.get_cell_at_position(at_position)
	var header_size = cells.cell_control_size
	
	# Deselect
	if not Input.is_physical_key_pressed(KEY_CTRL): cells.deselect_all()
	
	# Select all
	if header_position == header_position.clamp(Vector2.ZERO, header_size): 
		cells.select_all()
	# Select column
	elif header_position.y < header_size.y:
		cells.select_range(Rect2(cell.x, 0, 1, rows))
		cells.focus(cell)
	# Select row
	elif header_position.x < header_size.x:
		cells.select_range(Rect2(0, cell.y, columns, 1))
		cells.focus(cell)
	# Select cell
	else:
		if cells.cell_focused != cell: editing = false
		cells.select(cell)
		cells.focus(cell)

func get_scroll() -> Vector2:
	var parent = get_parent()
	return Vector2(parent.scroll_horizontal, parent.scroll_vertical)

# Render ========================================
func render(font: Font, offset: Vector2 = Vector2.ZERO) -> void:
	var COLOR_EDIT := Color(COLOR_SELECTION, 0.5)
	
	var font_color_header := Color("#d6d6d6")
	var font_color_value := Color.WHITE
	
	var draw_pos: Vector2
	var column_sizes = cells.cache_columns
	var row_sizes = cells.cache_rows
	var selected: bool
	var header_size = cells.cell_control_size
	
	# Background
	var node_size = custom_minimum_size
	draw_rect(Rect2(Vector2.ZERO, node_size), COLOR_CELL)
	
	# Draw cells
	draw_pos = header_size
	for y in range(rows):
		draw_pos.x = header_size.x
		for x in range(columns):
			var value = data.get_value(x, y)
			var cell = Vector2(x, y)
			var value_pos = draw_pos + Vector2(4, header_size.y/2)
			
			# Draw focused cell
			if cells.is_cell_focused(cell):
				draw_rect(Rect2(draw_pos, Vector2(column_sizes[x], row_sizes[y])), COLOR_SELECTION, true)
				if editing and Time.get_ticks_msec()%1000 > 500:
					var text_size = Vector2.ZERO if not value else font.get_string_size(str(value).substr(0, cursor_x), HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
					draw_string(font, value_pos + Vector2(text_size.x-6, 0), " |", 0, -1, 12, font_color_value)
			
			# Draw edited cells
			elif cells.is_cell_selected(cell):
				draw_rect(Rect2(draw_pos, Vector2(column_sizes[x], row_sizes[y])), COLOR_EDIT, true)
			
			# Draw value
			if value:
				draw_string(font, value_pos, str(value), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, font_color_value)
			
			# Update
			draw_pos.x += column_sizes[x]
		draw_pos.y += row_sizes[y]
	
	# Draw grid
	draw_rect(Rect2(Vector2.ZERO, node_size).grow_side(SIDE_RIGHT, 1), COLOR_BORDER, false)
	draw_pos = Vector2(header_size.x+1, offset.y)
	for x in range(columns):
		draw_line(draw_pos, draw_pos + Vector2(0, node_size.y-offset.y), COLOR_BORDER)
		draw_pos.x += column_sizes[x]
		
	draw_pos = Vector2(offset.x, header_size.y)
	for y in range(rows):
		draw_line(draw_pos, draw_pos + Vector2(node_size.x-offset.x, 0), COLOR_BORDER)
		draw_pos.y += row_sizes[y]
	
	# Draw headers
	draw_pos = Vector2(header_size.x, offset.y)
	for x in range(columns):
		draw_rect_border(Rect2(draw_pos, Vector2(column_sizes[x], header_size.y)), COLOR_HEADER, COLOR_BORDER)
		draw_string(font, draw_pos + Vector2(column_sizes[x]/2-4, header_size.y/2), str(x), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, font_color_header)
		draw_pos.x += column_sizes[x]
		
	draw_pos = Vector2(offset.x, header_size.y)
	for y in range(rows):
		draw_rect_border(Rect2(draw_pos, Vector2(header_size.x, row_sizes[y])), COLOR_HEADER, COLOR_BORDER)
		draw_string(font, draw_pos + Vector2(4, header_size.y/2), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, font_color_header)
		draw_pos.y += row_sizes[y]
	
	draw_rect_border(Rect2(offset, header_size), COLOR_HEADER, COLOR_BORDER)

func draw_rect_border(rect: Rect2, fill: Color, border: Color):
	draw_rect(rect, fill, true)
	rect.position += Vector2.ONE
	draw_rect(rect, border, false, 1)
