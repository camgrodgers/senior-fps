extends CSGSphere


var occupied = false
var NodeType = null


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	use_collision = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
