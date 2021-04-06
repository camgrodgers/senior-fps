extends HitScanWeapon
class_name GrenadeHeld

signal grenade_throw

onready var mesh = $Model/Grenade_3

var GrenadeInstance = preload("res://Equippables/GrenadeThrown.tscn")




func _ready():
	ammo_loaded = 5
	AMMO_PER_MAG = 5
	ammo_backup = 5
	#mesh.visible = false
	$AnimationPlayer.play_backwards("Raise")
	

func _physics_process(delta):
	chambering = clamp(chambering - delta, 0, 0.15)
	_is_active = false
	
	if $AnimationPlayer.is_playing():
		return
	
		
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
			return
		if not (raised and chambering == 0 and ammo_loaded > 0):
			return
		
		$AnimationPlayer.play("Fire")
		emit_signal("grenade_throw")
		
		ammo_loaded -=1
		$Model/Grenade_3.visible = false
		yield(get_tree().create_timer(1.76),"timeout")
		emit_signal("expose_ammo_count", ammo_loaded, ammo_backup, AMMO_PER_MAG)
		chambering = 0.15
		$Model/Grenade_3.visible = true

func unequip():
	self.queue_free()

func equip():
	pass

func throw_grenade(weapon_holder: Spatial) -> void:
	var GrenadeHeld = GrenadeInstance.instance()
	weapon_holder.add_child(GrenadeHeld)
	get_tree().root.add_child(GrenadeHeld)
	GrenadeHeld.global_transform = weapon_holder.global_transform
	GrenadeHeld.set_as_toplevel(true)
	GrenadeHeld.apply_impulse(Vector3(0,0,0),-GrenadeHeld.global_transform.basis.z * 20)
	yield(get_tree().create_timer(3.25 - 1.76),"timeout")


