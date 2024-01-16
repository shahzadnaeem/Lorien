class_name BrushCursor
extends BaseCursor

# -------------------------------------------------------------------------------------------------
func _draw():
	var radius := _brush_size
	
	draw_arc(Vector2.ZERO, radius, 0, PI*2, 32, Color.black, 1.0, true)
	draw_circle(Vector2.ZERO, radius*0.25, Color.black)

# -------------------------------------------------------------------------------------------------
func change_size(brush_size: int) -> void:
	_brush_size = brush_size
	update()
