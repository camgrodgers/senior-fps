extends RigidBody

export var(String) weapon_name = ""

func _on_RigidBody_body_entered(body):
	if body is Player:
		
