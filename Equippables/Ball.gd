extends RigidBody


var use_item_alt_pressed: bool = false
var use_item_pressed: bool = false
var is_active: bool = false

var ray: RayCast = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func unequip():
	$CollisionShape.disabled = false
	pass
func equip():
	translation = Vector3(0, 0, -1)
	$CollisionShape.disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
