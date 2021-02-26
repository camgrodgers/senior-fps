extends HitScanWeapon
class_name SKS

func _physics_process(delta):
	chambering = clamp(chambering - delta, 0, 0.15)
	_is_active = false
	
	if $AnimationPlayer.is_playing():
		return
	
	if _secondary_pressed:
		_is_active = true
		if not raised:
			$AnimationPlayer.play("Raise")
	else:
		if raised:
			$AnimationPlayer.play_backwards("Raise")
		
	if _primary_pressed:
		if not _secondary_pressed:
			$AnimationPlayer.play("Melee")
			
			return
		if not (_secondary_pressed and raised and chambering == 0):
#			print("didn't fire")
			return
#		print("fired")
		
		$AnimationPlayer.play("Fire")
		chambering = 0.15
		_fire_ray(1, 1)
		emit_signal("recoil", 4)

func unequip():
	self.queue_free()

func equip():
	pass

func _ready():
	$AnimationPlayer.play_backwards("Raise")

func inflict_melee_damage():
	var bodies: Array = $Model/Area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage()
		if body is RigidBody:
			var force = global_transform.origin.direction_to(body.translation) / 2
			body.apply_central_impulse(force)
