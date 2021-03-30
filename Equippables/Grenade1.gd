extends RigidBody

onready var blastArea = $Area

onready var grenade_node = $MeshInstance

onready var blast_image = $AnimatedSprite3D

onready var blast_sound = $blast_sound

var ammo_amount = 5

func throw():
	set_as_toplevel(true)
	apply_impulse(-global_transform.basis.z, global_transform.basis.z * 20)
	
	
func _ready():
	blast_image.visible = false
	




func _on_Timer_timeout():
	if ammo_amount > 0:
		grenade_node.visible = false
		blast_image.visible = true
		var objects = blastArea.get_overlapping_bodies()
		for object in objects:
			var env_world = get_world().direct_space_state
			if object.has_method("take_damage"):
				var collide = env_world.intersect_ray(global_transform.origin,object.global_transform.origin)
				if collide.collider.has_method("take_damage"):
					object.take_damage(1.0)
				
		blast_sound.play()
		yield(get_tree().create_timer(0.05),'timeout')
		blast_image.visible = false
		ammo_amount -= 1
		yield(get_tree().create_timer(1.18 - 0.05),"timeout")
		queue_free()
