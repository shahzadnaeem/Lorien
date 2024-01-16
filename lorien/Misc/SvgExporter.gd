class_name SvgExporter
extends Reference

# TODOs
# - Stroke width / pressure data. Line cap style

# -------------------------------------------------------------------------------------------------
const EDGE_MARGIN := 30

# -------------------------------------------------------------------------------------------------
func export_svg(strokes: Array, background: Color, path: String) -> void:
	var start_time := OS.get_ticks_msec()
	
	# Open file
	var file := File.new()
	var err := file.open(path, File.WRITE)
	if err != OK:
		printerr("Failed to open file for writing")
		return
	
	# Calculate total canvas dimensions
	var max_dim := BrushStroke.MIN_VECTOR2
	var min_dim := BrushStroke.MAX_VECTOR2
	for stroke in strokes:
		min_dim.x = min(min_dim.x, stroke.top_left_pos.x)
		min_dim.y = min(min_dim.y, stroke.top_left_pos.y)
		max_dim.x = max(max_dim.x, stroke.bottom_right_pos.x)
		max_dim.y = max(max_dim.y, stroke.bottom_right_pos.y)
	var size := max_dim - min_dim

	#xSN Fixed margin - not dependent on image aspect ratio	
	var margin := Vector2( EDGE_MARGIN, EDGE_MARGIN )
	size += margin
	var origin := min_dim - margin/2
	
	# Write svg to file
	_svg_start(file, origin, size)
	_svg_rect(file, origin, size, background)
	for stroke in strokes:
		_svg_polyline(file, stroke)
	_svg_end(file)
	
	# Flush and close the file
	file.flush()
	file.close()
	print("Exported %s in %d ms" % [path, (OS.get_ticks_msec() - start_time)])

# -------------------------------------------------------------------------------------------------
func _svg_start(file: File, origin: Vector2, size: Vector2) -> void:
	var params := [origin.x, origin.y, size.x, size.y]
	var svg := "<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"%.1f %.1f %.1f %.1f\">\n" % params
	file.store_string(svg)

# -------------------------------------------------------------------------------------------------
func _svg_end(file: File) -> void:
	file.store_string("</svg>") 

# -------------------------------------------------------------------------------------------------
func _svg_rect(file: File, origin: Vector2, size: Vector2, color: Color) -> void:
	var params := [origin.x, origin.y, size.x, size.y, color.to_html(false)]
	var rect := "<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" fill=\"#%s\" />\n" % params
	file.store_string(rect)

# -------------------------------------------------------------------------------------------------

func pr2w(size:int, pressure:float) -> int:
	return int((size*1.0)*((pressure*1.0)/255.0))


# TODO: Brush strokes bit rough at edges, but better than before

func _svg_polyline(file: File, stroke: BrushStroke) -> void:
	
	var point_count := stroke.points.size()
	var multi_width := false
	var curr_width := pr2w(stroke.size, stroke.pressures[0])

	if point_count > 2:
		for i in range(point_count):
			var width:int = (stroke.size*1.0)*((stroke.pressures[i]*1.0)/255.0)
			if curr_width != width:
				curr_width = width
				multi_width = true
				break

	if multi_width:
		file.store_string("<!-- %s -->\n" % "Multi width line");
		for i in range(point_count - 2):
			file.store_string("<polyline points=\" %.1f %.1f, %.1f %.1f" % [stroke.points[i].x, stroke.points[i].y, stroke.points[i+2].x, stroke.points[i+2].y])
			
			var width: int = (stroke.size*1.0)*((stroke.pressures[i]*1.0)/255.0)
			file.store_string("\" style=\"fill:none;stroke:#%s;stroke-width:%d\"/>\n" % [stroke.color.to_html(false), width])
	else:
		file.store_string("<polyline points=\"")

		var idx := 0
		for point in stroke.points:
			point += stroke.global_position
			if idx < point_count-1:
				file.store_string("%.1f %.1f, " % [point.x, point.y])
			else:
				file.store_string("%.1f %.1f" % [point.x, point.y])
			idx += 1

		var width: int = (stroke.size*1.0)*((stroke.pressures[0]*1.0)/255.0)
		file.store_string("\" style=\"fill:none;stroke:#%s;stroke-width:%d\"/>\n" % [stroke.color.to_html(false), width])

# -------------------------------------------------------------------------------------------------




