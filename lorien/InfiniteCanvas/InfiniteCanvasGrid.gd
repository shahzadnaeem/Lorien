class_name InfiniteCanvasGrid
extends Node2D

# -------------------------------------------------------------------------------------------------
export var camera_path: NodePath
var _enabled: bool
var _pattern: int = Types.GridPattern.DOTS
var _camera: Camera2D
var _grid_size := Config.DEFAULT_GRID_SIZE
var _grid_color: Color
var _grid_angle := Config.DEFAULT_GRID_ANGLE

# -------------------------------------------------------------------------------------------------
func _ready():
	_grid_size = Settings.get_value(Settings.APPEARANCE_GRID_SIZE, Config.DEFAULT_GRID_SIZE)
	_grid_angle = Settings.get_value(Settings.APPEARANCE_GRID_ANGLE, Config.DEFAULT_GRID_ANGLE)
	_pattern = Settings.get_value(Settings.APPEARANCE_GRID_PATTERN, Config.DEFAULT_GRID_PATTERN)
	
	_camera = get_node(camera_path)
	_camera.connect("zoom_changed", self, "_on_zoom_changed")
	_camera.connect("position_changed", self, "_on_position_changed")
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

# -------------------------------------------------------------------------------------------------
func enable(e: bool) -> void:
	set_process(e)
	visible = e

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(zoom: float) -> void: update()
func _on_position_changed(pos: Vector2) -> void: update()
func _on_viewport_size_changed() -> void: update()

# -------------------------------------------------------------------------------------------------
func set_grid_size(size: int) -> void:
	_grid_size = size
	update()

# -------------------------------------------------------------------------------------------------
func set_grid_pattern(pattern: int) -> void:
	_pattern = pattern
	update()

# -------------------------------------------------------------------------------------------------
func set_canvas_color(c: Color) -> void:
	_grid_color = c * 1.25
	update()

# -------------------------------------------------------------------------------------------------
func set_grid_scale(size: float):
	_grid_size = Config.DEFAULT_GRID_SIZE * size
	update()

# -------------------------------------------------------------------------------------------------
func set_grid_angle(angle: float):
	_grid_angle = angle
	update()

# -------------------------------------------------------------------------------------------------

func _set_grid_transform(middle) -> void:
	var THETA := deg2rad(_grid_angle)
	
	var tfm := Transform2D()
	tfm.x.x = cos(THETA)
	tfm.y.y = cos(THETA)
	tfm.x.y = sin(THETA)
	tfm.y.x = -sin(THETA)

	# Calculate translation for restoring to 'centre' - offset as it's relative to 'main'
	var origin = tfm * middle - middle
	tfm.origin = -origin

	# print("Middle: %s" % middle)
	# print("Tfm: %s" % tfm)

	draw_set_transform_matrix(tfm)
	
	# Alternative transform calculation
#
#	var tfm2 := Transform2D()
#	# Translate back to centre
#	tfm2.origin = middle
#	# Rotate
#	tfm2.x.x = cos(THETA)
#	tfm2.y.y = cos(THETA)
#	tfm2.x.y = sin(THETA)
#	tfm2.y.x = -sin(THETA)
#
#	var tfm3 := Transform2D()
#	# Translate centre to origin
#	tfm3.origin = -middle
#
#	var tfmt := tfm2 * tfm3  # NOTE: when applied to a point, tfm3 is applied first, as is required
#	print("Tfmt: %s" % tfmt)

func _draw() -> void:
	var size = get_viewport().size  * _camera.zoom
	var zoom = _camera.zoom.x
	var offset = _camera.offset
	var grid_size := int(ceil((_grid_size * pow(zoom, 0.75))))

	var middle = Vector2( offset.x + size.x / 2, offset.y + size.y / 2)

	draw_line(middle + Vector2( -50, 0), middle + Vector2( 50, 0), Color.white * 0.3, 2.0)
	draw_line(middle + Vector2( 0, -50), middle + Vector2( 0, 50), Color.white * 0.3, 2.0)

	_set_grid_transform(middle)
	
	match _pattern:
		Types.GridPattern.DOTS:
			var dot_size := int(ceil(grid_size * 0.12))
			var x_start := int((offset.x - size.x)/ grid_size) - 1
			var x_end := int((2*size.x + offset.x) / grid_size) + 1
			var y_start := int((offset.y - size.y)/ grid_size) - 1
			var y_end = int((2*size.y + offset.y) / grid_size) + 1
			
			for x in range(x_start, x_end):
				for y in range(y_start, y_end):
					var pos := Vector2(x, y) * grid_size
					draw_rect(Rect2(pos.x, pos.y, dot_size, dot_size), _grid_color)

		Types.GridPattern.LINES:
			#print("Cam offset: %s, zoom: %s, [%s]" % [ _camera.offset, _camera.zoom, get_transform()])
			#print("Middle: %s -> %s delta: %s" % [ middle, tfm * middle, tfm * middle - middle ] )
			
			# Vertical lines
			var start_index := int((offset.x - size.x) / grid_size) - 1
			var end_index := int((2*size.x + offset.x) / grid_size) + 1

			for i in range(start_index, end_index):
				if i % 5 == 0:
					draw_line(Vector2(i * grid_size, offset.y + size.y*2), Vector2(i * grid_size, offset.y - size.y*2), _grid_color, 2.5)
				else:
					draw_line(Vector2(i * grid_size, offset.y + size.y*2), Vector2(i * grid_size, offset.y - size.y*2), _grid_color)

			# Horizontal lines
			start_index = int((offset.y - size.y) / grid_size) - 1
			end_index = int((2*size.y + offset.y) / grid_size) + 1

			for i in range(start_index, end_index):
				if i % 5 == 0:
					draw_line(Vector2(offset.x + size.x * 2, i * grid_size), Vector2(offset.x - size.x*2, i * grid_size), _grid_color, 2.5)
				else:
					draw_line(Vector2(offset.x + size.x * 2, i * grid_size), Vector2(offset.x - size.x*2, i * grid_size), _grid_color)
