class_name LineTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const SNAP_STEP := deg2rad(15.0)

# -------------------------------------------------------------------------------------------------
#export var pressure_curve: Curve

var _snapping_enabled := false
var _head: Vector2
var _tail: Vector2

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
#	_cursor.set_pressure(1.0)

	var hold_pressure := Input.is_key_pressed(KEY_CONTROL)
	
	# Snap modifier
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			_snapping_enabled = event.pressed
	
	# Moving the tail
	elif event is InputEventMouseMotion:
		if performing_stroke:
			if !hold_pressure:
				_cursor.set_pressure(event.pressure)
				
			_tail = _get_position(_snapping_enabled)

			remove_all_stroke_points()
			add_subdivided_line(_head, _tail, _cursor.get_pressure()) #pressure_curve.interpolate(0.5))
	
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke()
				_head = _get_position(false)
				_tail = _head
			elif !event.pressed && performing_stroke:
				remove_all_stroke_points()
				add_subdivided_line(_head, _tail, _cursor.get_pressure()) #pressure_curve.interpolate(0.5))
				_cursor.reset_pressure()
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _get_position(snap:bool) -> Vector2:
	var position: Vector2 = _cursor.global_position

	if snap:
		var mouse_angle := _head.angle_to_point(_cursor.global_position) + (SNAP_STEP / 2.0)
		var snapped_angle := floor(mouse_angle / SNAP_STEP) * SNAP_STEP
		var line_length := _head.distance_to(_cursor.global_position)
		position = Vector2(-line_length, 0).rotated(snapped_angle) + _head

	return position
