extends HitScanWeapon
class_name SKS

func _physics_process(delta):
	chambering = clamp(chambering - delta, 0, 0.15)
	_is_active = false
	
	if _secondary_pressed:
		_is_active = true
		if not raised:
			$AnimationPlayer.play("Raise")
	else:
		if raised:
			$AnimationPlayer.play_backwards("Raise")
		
	if _primary_pressed:
		if not (_secondary_pressed and raised and chambering == 0):
#			print("didn't fire")
			return
#		print("fired")
		
		$AnimationPlayer.play("Fire")
		chambering = 0.15
		fire_ray(1, 1)

func unequip():
	self.queue_free()

func equip():
	pass

func _ready():
	$AnimationPlayer.play_backwards("Raise")
