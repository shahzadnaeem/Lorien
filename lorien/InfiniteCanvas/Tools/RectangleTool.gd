class_name RectangleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _start_position_top_left: Vector2

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	var should_draw_square := Input.is_key_pressed(KEY_SHIFT)
	var hold_pressure := Input.is_key_pressed(KEY_CONTROL)

	if event is InputEventMouseMotion:
		if performing_stroke:
			if event.pressure > 0.0:
				if !hold_pressure:
					_cursor.set_pressure(event.pressure)
			remove_all_stroke_points()
			_make_rectangle(_cursor.get_pressure(), should_draw_square)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke()
				_start_position_top_left = _cursor.global_position
				_make_rectangle(_cursor.get_pressure(), should_draw_square)
			elif !event.pressed && performing_stroke:
				remove_all_stroke_points()
				_make_rectangle(_cursor.get_pressure(), should_draw_square)
				end_stroke()
				_cursor.reset_pressure()

# -------------------------------------------------------------------------------------------------
func _make_rectangle(pressure: float, should_draw_square:bool) -> void:
	var bottom_right := _cursor.global_position

	var height := bottom_right.y - _start_position_top_left.y
	var width  := bottom_right.x - _start_position_top_left.x
	
	var hs = sign(height)
	var ws = sign(width)
	
	if should_draw_square:
		height = max(abs(height), abs(width))
		width = height*ws
		height = height*hs
		
		bottom_right.y = _start_position_top_left.y + height
		bottom_right.x = _start_position_top_left.x + width
		
	var min_x = min(_start_position_top_left.x, bottom_right.x)
	var min_y = min(_start_position_top_left.y, bottom_right.y)
	
	width = abs(width)
	height = abs(height)

	var top_left    := Vector2(min_x,min_y)
	var top_right   := top_left + Vector2(width, 0)
	bottom_right    =  top_right + Vector2(0, height)
	var bottom_left := top_left + Vector2(0, height)
	
	# Trace out the rectangle
	add_stroke_point(top_left, pressure)
	add_stroke_point(top_right, pressure)
	add_stroke_point(bottom_right, pressure)
	add_stroke_point(bottom_left, pressure)
	# overlap to ensure SVG does not have gap at top left corner
	add_stroke_point(top_left, pressure)
	add_stroke_point(top_right, pressure)
