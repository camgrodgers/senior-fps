extends CSGSphere

# Length of time enemy should stop on node
export var time_in_seconds: float = 1.0

var occupied: bool = false
var occupied_by = null
var visible_to_player: bool = false

func _ready():
	visible = false
	use_collision = false

