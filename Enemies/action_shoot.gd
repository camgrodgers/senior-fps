extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var preconditions = {
	"has_target" : true,
	"in_cover": true,
	"can_see_player": true
	
}

export var effects = {
	"has_target" : false
}

export var cost = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass