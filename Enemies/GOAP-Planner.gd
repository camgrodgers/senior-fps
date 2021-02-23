extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var actions: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for a in get_children():
		actions.append(a)
	
func plan_actions():
	
	return actions[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
