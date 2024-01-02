class_name RectangleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const PRESSURE := 0.5

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _start_position_top_left: Vector2

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	#_cursor.set_pressure(1.0)

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
	#pressure = pressure_curve.interpolate(pressure)
	
	var bottom_right_point := _cursor.global_position

	var height := bottom_right_point.y - _start_position_top_left.y
	var width  := bottom_right_point.x - _start_position_top_left.x
	
	if should_draw_square:
		height = max(height, width)
		width = height
		bottom_right_point.y = _start_position_top_left.y + height
		bottom_right_point.x = _start_position_top_left.x + width
	
	var top_right_point   := _start_position_top_left + Vector2(width, 0)
	var bottom_left_point := _start_position_top_left + Vector2(0, height)
	
	var w_offset := width*0.02
	var h_offset := height*0.02
	
	add_subdivided_line(_start_position_top_left, top_right_point - Vector2(w_offset, 0), pressure)
	add_subdivided_line(top_right_point, bottom_right_point - Vector2(0, h_offset), pressure)
	add_subdivided_line(bottom_right_point, bottom_left_point + Vector2(w_offset, 0), pressure)
	add_subdivided_line(bottom_left_point, _start_position_top_left + Vector2(0, h_offset), pressure)
	add_subdivided_line(_start_position_top_left, _start_position_top_left + Vector2(w_offset, 0), pressure)
