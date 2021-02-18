extends CSGSphere


var occupied: bool = false
var NODE_TYPE = null
var occupied_by = null
var visible_to_player: bool = false

func _ready():
	visible = false

