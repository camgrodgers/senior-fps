extends HitScanWeapon
class_name AK47


func _ready():
	ammo_loaded = 20
	AMMO_PER_MAG = 20
	ammo_backup = 100
	$AnimationPlayer.play_backwards("Raise")
	

func _physics_process(delta):
	chambering = clamp(chambering - delta, 0, 0.15)
	_is_active = false
	
	if $AnimationPlayer.is_playing():
		return
	
	if _reload_pressed:
		_is_active = true
		$AnimationPlayer.play("Reload")
		
	if _secondary_pressed:
		_is_active = true
		signals.emit_signal("expose_ammo_count", ammo_loaded, ammo_backup, AMMO_PER_MAG)
		if not raised:
			$AnimationPlayer.play("Raise")
	else:
		if raised:
			$AnimationPlayer.play_backwards("Raise")
			signals.emit_signal("hide_ammo_count")
		
	if _primary_pressed:
		if not _secondary_pressed:
			$AnimationPlayer.play("Melee")
			return
		if not (raised and chambering == 0 and ammo_loaded > 0):
			return
		
		$AnimationPlayer.play("Fire")
		_spend_round()
		signals.emit_signal("expose_ammo_count", ammo_loaded, ammo_backup, AMMO_PER_MAG)
		chambering = 0.15
		_fire_ray(1, 1)
		signals.emit_signal("recoil", 4)

func unequip():
	self.queue_free()

func equip():
	pass


func inflict_melee_damage():
	var bodies: Array = $Model/Area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage()
		if body is RigidBody:
			var force = global_transform.origin.direction_to(body.translation) / 2
			body.apply_central_impulse(force)
