extends Node
class_name Types

# -------------------------------------------------------------------------------------------------
enum Tool {
	BRUSH,
	RECTANGLE,
	CIRCLE,
	LINE,
	ERASER,
	SELECT,
}

# -------------------------------------------------------------------------------------------------
enum AAMode {
	NONE,
	OPENGL_HINT,
	TEXTURE_FILL
}

# -------------------------------------------------------------------------------------------------
enum GridPattern {
	DOTS,
	LINES,
	NONE
}

# -------------------------------------------------------------------------------------------------
enum UITheme {
	DARK,
	LIGHT
}

# -------------------------------------------------------------------------------------------------
enum BrushRoundingType {
	FLAT = 0,
	ROUNDED = 1
}

# -------------------------------------------------------------------------------------------------
enum UIScale {
	AUTO,
	CUSTOM
}

# -------------------------------------------------------------------------------------------------
class CanvasInfo:
	var point_count: int
	var stroke_count: int
	var current_pressure: float
	var selected_lines : int
	var pen_inverted : bool

# -------------------------------------------------------------------------------------------------
class StdKeys:
	var shift: bool
	var ctrl: bool
	
	func _to_string() -> String:
		return "shift: %s, ctrl: %s" % [shift, ctrl]
