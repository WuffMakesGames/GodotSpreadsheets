class_name CSV extends Node

static func parse_string(string: String) -> Array[Array]:
	var columns: PackedStringArray = string.replace("\r", "").split("\n")
	var columns_parsed: Array[Array] = []
	for i in range(0, len(columns)-1):
		columns_parsed.append(parse_line(columns[i]))
	return columns_parsed

static func get_string(array: Array[Variant]) -> String:
	var output: String = ""
	for row in array:
		for value in row:
			if not value: value = ""
			else: value = str(value)
			if value.contains(",") or value.contains('"'):
				value = str('"', value.replace('"', '""'), '"')
			output += str(value, ",")
		output += "\n"
	return output

static func parse_line(line: String) -> Array[Variant]:
	var row: Array[Variant] = []
	var pos = 0
	var sep = ","
	while true:
		var char = line.substr(pos, 1)
		if char == "": break
		if char == '"':
			var end = pos + 1
			while true:
				if line.substr(end, 2) == '""': end += 2
				elif line.substr(end, 1) == '"': break
				else: end += 1
			row.append(line.substr(pos+1, end-pos-1).replace('""', '"'))
			pos = end + 2
		else:
			var end = line.find(",", pos+1)
			if line.substr(pos, 1) == ",":
				row.append("")
				pos += 1
			elif end != -1:
				row.append(line.substr(pos, end-pos))
				pos = end + 1
			else:
				row.append(line.substr(pos))
				break
	return row
