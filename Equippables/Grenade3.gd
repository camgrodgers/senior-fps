#extends RigidBody

extends HitScanWeapon
class_name Grenade3

signal throwGrenade

onready var blastArea = $Area

onready var grenade_node = $MeshInstance

onready var blast_image = $AnimatedSprite3D

onready var blast_sound = $blast_sound


func _ready():
	ammo_loaded = 5
	AMMO_PER_MAG = 5
	ammo_backup = 100
	$AnimationPlayer.play_backwards("Raise")
	blast_image.visible = false
	

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
		emit_signal("expose_ammo_count", ammo_loaded, ammo_backup, AMMO_PER_MAG)
		if not raised:
			$AnimationPlayer.play("Raise")
	else:
		if raised:
			$AnimationPlayer.play_backwards("Raise")
			emit_signal("hide_ammo_count")
		
	if _primary_pressed:
		if not _secondary_pressed:
			$AnimationPlayer.play("Melee")
			return
		if not (raised and chambering == 0 and ammo_loaded > 0):
			return
		
		$AnimationPlayer.play("Fire")
		emit_signal("throwGrenade")
		_spend_round()
		emit_signal("expose_ammo_count", ammo_loaded, ammo_backup, AMMO_PER_MAG)
		chambering = 0.15
		_fire_ray(1, 1)
		emit_signal("recoil", 4)

func unequip():
	self.queue_free()

func equip():
	pass

#func throw():
	#set_as_toplevel(true)
	#apply_impulse(-global_transform.basis.z, global_transform.basis.z * 20)

func inflict_melee_damage():
	var bodies: Array = $Model/Area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage()
		if body is RigidBody:
			var force = global_transform.origin.direction_to(body.translation) / 2
			body.apply_central_impulse(force)

func explosion():
	grenade_node.visible = false
	blast_image.visible = true
	var objects = blastArea.get_overlapping_bodies()
	for object in objects:
		var env_world = get_world().direct_space_state
		if object.has_method("take_damage"):
			var collide = env_world.intersect_ray(global_transform.origin,object.global_transform.origin)
			if collide.collider.has_method("take_damage"):
				object.take_damage()
				
	blast_sound.play()
	yield(get_tree().create_timer(0.05),'timeout')
	blast_image.visible = false
	yield(get_tree().create_timer(1.18 - 0.05),"timeout")
	queue_free()
	

#func _on_Timer_timeout():
	#grenade_node.visible = false
	#blast_image.visible = true
	#var objects = blastArea.get_overlapping_bodies()
	#for object in objects:
		#var env_world = get_world().direct_space_state
		#if object.has_method("take_damage"):
		#	var collide = env_world.intersect_ray(global_transform.origin,object.global_transform.origin)
		#	if collide.collider.has_method("take_damage"):
		#		object.take_damage()
		#		
	#blast_sound.play()
	#yield(get_tree().create_timer(0.05),'timeout')
	#blast_image.visible = false
	#yield(get_tree().create_timer(1.18 - 0.05),"timeout")
	#queue_free()
	
