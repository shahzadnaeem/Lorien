class_name BaseCursor, "res://Assets/Icons/cursor_icon.png"
extends Sprite

# -------------------------------------------------------------------------------------------------
var _brush_size: int
var _pressure := 1.0

# Only update pressure some ms after previous update - can drop to 0 when pen is lifted otherwise
const PRESSURE_TICKS:int = 100
var _last_pressure_tick := 0

onready var _camera: Camera2D = get_viewport().get_node("Camera2D")

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _input(event):
	if event is InputEventMouseMotion:
		_update_position()

# -------------------------------------------------------------------------------------------------
func _update_position():
	global_position = _camera.get_global_mouse_position()

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	var now := Time.get_ticks_msec()
	
	var dropping = pressure < _pressure
	
	if !dropping:
		_pressure = pressure
		_last_pressure_tick = now
	elif now - _last_pressure_tick >= PRESSURE_TICKS:
		if _pressure - pressure > 0.2:
			_pressure -= 0.2
		else:
			_pressure = pressure
		_last_pressure_tick = now


func get_pressure() -> float:
	return _pressure

func reset_pressure() -> void:
	_pressure = 0.0

# -------------------------------------------------------------------------------------------------
func change_size(value: int) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_canvas_position_changed(pos: Vector2) -> void:
	_update_position()

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(value: float) -> void:
	pass
