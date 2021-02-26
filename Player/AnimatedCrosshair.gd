extends Control
class_name AnimatedCrosshair

onready var left: ColorRect = $Lines/Left
onready var right: ColorRect = $Lines/Right
onready var top: ColorRect = $Lines/Top
onready var bottom: ColorRect = $Lines/Bottom
#onready var left: ColorRect = $Left
#onready var right: ColorRect = $Right
#onready var top: ColorRect = $Top
#onready var bottom: ColorRect = $Bottom

# width is distance between inside points of lines
export var goal_width: float = 30
export var line_length: int = 20
var _width: float = 30

func _ready() -> void:
	_update_line_length()
	_update_expansion()

func _physics_process(delta):
	_width = lerp(_width, goal_width, delta * 10)
	_update_line_length()
	_update_expansion()

func _update_expansion() -> void:
	# Expanding the crosshair
	left.rect_position.x = (-1 * left.rect_size.x) - _width
	right.rect_position.x = _width
	top.rect_position.y = (-1 * top.rect_size.y) - _width
	bottom.rect_position.y = _width
	
	# Correcting for line width
	left.rect_position.y = -1 * left.rect_size.y / 2
	right.rect_position.y = -1 * right.rect_size.y / 2 
	top.rect_position.x = -1 * top.rect_size.x / 2 
	bottom.rect_position.x = -1 * bottom.rect_size.x / 2 
	
func _update_line_length() -> void:
	left.rect_min_size.x = line_length
	right.rect_min_size.x = line_length
	top.rect_min_size.y = line_length
	bottom.rect_min_size.y = line_length
