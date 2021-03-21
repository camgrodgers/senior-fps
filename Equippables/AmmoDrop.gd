extends RigidBody
class_name AmmoDrop

export(String) var weapon_name = ""
export(int) var ammo_amount = 0
export(bool) var enable_weapon = false
export(bool) var random_impulse = false

func _ready():
	if random_impulse:
		var impulse_vec = Vector3(0, 3, 0)
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		impulse_vec.x = rng.randf_range(-5, 5)
		impulse_vec.z = rng.randf_range(-5, 5)
		self.apply_central_impulse(impulse_vec)

func _on_Area_body_entered(body):
	if body is Player:
		body.add_weapon_ammo(weapon_name, ammo_amount, enable_weapon)
		self.queue_free()
