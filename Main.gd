extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_level = null

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level = load("res://Levels/TestLevel.tscn")
	current_level = current_level.instance()
	add_child(current_level)
	$Menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
