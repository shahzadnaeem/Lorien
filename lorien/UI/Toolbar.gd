extends ScrollContainer
class_name Toolbar

signal new_project
signal open_project(filepath)
signal save_project
signal clear_canvas
signal undo_action
signal redo_action
signal toggle_brush_color_picker
signal brush_size_changed(size)
signal tool_changed(t)
signal toggle_grid(state)

# -------------------------------------------------------------------------------------------------
const BUTTON_HOVER_COLOR = Color("50ffd6")
const BUTTON_CLICK_COLOR = Color("50ffd6")
const BUTTON_NORMAL_COLOR = Color.white

# -------------------------------------------------------------------------------------------------
export var file_dialog_path: NodePath

onready var _settings_dialog: WindowDialog = $"%SettingsDialog"

onready var _new_button: TextureButton = $Console/Left/NewFileButton
onready var _save_button: TextureButton = $Console/Left/SaveFileButton
onready var _open_button: TextureButton = $Console/Left/OpenFileButton
onready var _clear_canvas_button: TextureButton = $Console/Left/ClearCanvasButton
onready var _undo_button: TextureButton = $Console/Left/UndoButton
onready var _redo_button: TextureButton = $Console/Left/RedoButton
onready var _color_button: Button = $Console/Left/ColorButton
onready var _brush_size_label: Label = $Console/Left/BrushSizeLabel
onready var _brush_size_slider: HSlider = $Console/Left/BrushSizeSlider
onready var _fullscreen_btn: TextureButton = $Console/Right/FullscreenButton
onready var _tool_btn_brush: TextureButton = $Console/Left/BrushToolButton
onready var _tool_btn_rectangle: TextureButton = $Console/Left/RectangleToolButton
onready var _tool_btn_circle: TextureButton = $Console/Left/CircleToolButton
onready var _tool_btn_line: TextureButton = $Console/Left/LineToolButton
onready var _tool_btn_eraser: TextureButton = $Console/Left/EraserToolButton
onready var _tool_btn_selection: TextureButton = $Console/Left/SelectionToolButton
onready var _grid_btn = $Console/Left/GridButton

var _last_active_tool_button: TextureButton
var grid_enabled: bool

# -------------------------------------------------------------------------------------------------
func _ready():
	var brush_size: int = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	_brush_size_label.text = str(brush_size)
	_brush_size_slider.value = brush_size
	_last_active_tool_button = _tool_btn_brush

	update_grid()
	
	_settings_dialog.connect("grid_pattern_changed", self, "_on_grid_pattern_changed")

# -------------------------------------------------------------------------------------------------
func update_grid():
	grid_enabled = Settings.get_value(Settings.APPEARANCE_GRID_PATTERN, Config.DEFAULT_GRID_PATTERN) != Types.GridPattern.NONE
	_grid_btn.set_pressed(grid_enabled)

# -------------------------------------------------------------------------------------------------
# Button clicked callbacks

func _on_NewFileButton_pressed(): emit_signal("new_project")
func _on_ClearCanvasButton_pressed(): emit_signal("clear_canvas")
func _on_UndoButton_pressed(): emit_signal("undo_action")
func _on_RedoButton_pressed(): emit_signal("redo_action")

# -------------------------------------------------------------------------------------------------
func enable_tool(tool_type: int) -> void:
	var btn: TextureButton
	match tool_type:
		Types.Tool.BRUSH: btn = _tool_btn_brush
		Types.Tool.LINE: btn = _tool_btn_line
		Types.Tool.ERASER: btn = _tool_btn_eraser
		Types.Tool.SELECT: btn = _tool_btn_selection
		Types.Tool.RECTANGLE: btn = _tool_btn_rectangle
		Types.Tool.CIRCLE: btn = _tool_btn_circle
	
	btn.toggle()
	_change_active_tool_button(btn)
	emit_signal("tool_changed", tool_type)

# -------------------------------------------------------------------------------------------------
func set_brush_color(color: Color) -> void:
	_color_button.get("custom_styles/normal").bg_color = color
	var lum := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
	var text_color := Color.black if lum > 0.4 else Color.white	
	_color_button.set("custom_colors/font_color", text_color)
	_color_button.set("custom_colors/font_color_hover", text_color)
	_color_button.set("custom_colors/font_color_pressed", text_color)
	_color_button.set("custom_colors/font_color_focus", text_color)
	_color_button.text = "#" + color.to_html(false)

# -------------------------------------------------------------------------------------------------
func set_fullscreen_toggle(pressed):
	_fullscreen_btn.set_pressed(pressed)

# -------------------------------------------------------------------------------------------------
func _on_OpenFileButton_pressed():
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.connect("file_selected", self, "_on_project_selected_to_open")
	file_dialog.connect("popup_hide", self, "_on_file_dialog_closed")
	file_dialog.invalidate()
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_project_selected_to_open(filepath: String) -> void:
	emit_signal("open_project", filepath)

# -------------------------------------------------------------------------------------------------
func _on_SaveFileButton_pressed():
	emit_signal("save_project")

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	Utils.remove_signal_connections(file_dialog, "file_selected")
	Utils.remove_signal_connections(file_dialog, "popup_hide")

# -------------------------------------------------------------------------------------------------
func _on_ColorButton_pressed():
	emit_signal("toggle_brush_color_picker")

# -------------------------------------------------------------------------------------------------
func _on_background_color_changed(color: Color) -> void:
	emit_signal("canvas_background_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_BrushSizeSlider_value_changed(value: float):
	var new_size := int(value)
	_brush_size_label.text = "%d" % new_size
	emit_signal("brush_size_changed", new_size)

# -------------------------------------------------------------------------------------------------
func _on_BrushToolButton_pressed():
	_change_active_tool_button(_tool_btn_brush)
	emit_signal("tool_changed", Types.Tool.BRUSH)

# -------------------------------------------------------------------------------------------------
func _on_RectangleToolButton_pressed() -> void:
	_change_active_tool_button(_tool_btn_rectangle)
	emit_signal("tool_changed", Types.Tool.RECTANGLE)

# -------------------------------------------------------------------------------------------------
func _on_CircleToolButton_pressed():
	_change_active_tool_button(_tool_btn_circle)
	emit_signal("tool_changed", Types.Tool.CIRCLE)	
	
# -------------------------------------------------------------------------------------------------
func _on_LineToolButton_pressed():
	_change_active_tool_button(_tool_btn_line)
	emit_signal("tool_changed", Types.Tool.LINE)

# -------------------------------------------------------------------------------------------------
func _on_EraserToolButton_pressed():
	_change_active_tool_button(_tool_btn_eraser)
	emit_signal("tool_changed", Types.Tool.ERASER)

# -------------------------------------------------------------------------------------------------
func _on_SelectToolButton_pressed():
	_change_active_tool_button(_tool_btn_selection)
	emit_signal("tool_changed", Types.Tool.SELECT)

# -------------------------------------------------------------------------------------------------
func _on_FullscreenButton_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)

# -------------------------------------------------------------------------------------------------
# OUT
func _on_toggle_grid(state):
	emit_signal("toggle_grid", state)

# IN
func _on_grid_pattern_changed(pattern):
	update_grid()

# -------------------------------------------------------------------------------------------------
func _change_active_tool_button(btn: TextureButton) -> void:
	if _last_active_tool_button != null:
		_last_active_tool_button.toggle()
	_last_active_tool_button = btn

# -------------------------------------------------------------------------------------------------
func get_brush_color_button() -> Control:
	return _color_button
