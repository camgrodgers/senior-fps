extends CSGSphere


var occupied = false
var NODE_TYPE = null
var occupied_by = null
var visible_to_player = false

func _ready():
	visible = false
	use_collision = false

