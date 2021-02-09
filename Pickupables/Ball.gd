extends RigidBody

var use_item_alt_pressed: bool = false
var use_item_pressed: bool = false
var is_active: bool = false

var ray: RayCast = null

func unequip():
	$CollisionShape.disabled = false
	
func pick_up():
	translation = Vector3(0, 0, 0)
	$CollisionShape.disabled = true
