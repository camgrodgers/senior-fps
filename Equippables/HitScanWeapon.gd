extends Spatial
class_name HitScanWeapon

signal recoil(force)

var _is_active: bool = false
var _ray: RayCast
var _primary_pressed: bool = false
var _secondary_pressed: bool = false
var _reload_pressed: bool = false
export var raised: bool = false
export var chambering: float = 0.0

var ammo_loaded: int
var ammo_backup: int
var AMMO_PER_MAG: int

func set_ray(ray: RayCast) -> void:
	_ray = ray

func set_inputs(primary_pressed: bool,
			secondary_pressed: bool,
			reload_pressed: bool) -> void:
	_primary_pressed = primary_pressed
	_secondary_pressed = secondary_pressed
	_reload_pressed = reload_pressed

func _fire_ray(damage: float, force_multiply: float) -> void:
	_ray.force_raycast_update()
	if !_ray.is_colliding(): return
	
	var obj = _ray.get_collider()
	if obj.has_method("take_damage"):
		obj.take_damage(damage)
	if obj is RigidBody:
		var force = (force_multiply *
				global_transform.origin.direction_to(obj.translation) / 4)
		obj.apply_central_impulse(force)

func _reload() -> void:
	if ammo_backup == 0:
		return
	var bullets_spent: int = AMMO_PER_MAG - ammo_loaded
	if bullets_spent == 0:
		return
	
	var bullets_adding = min(bullets_spent, ammo_backup)
	ammo_loaded += bullets_adding
	ammo_backup -= bullets_adding

func _spend_round() -> void:
	ammo_loaded = max(0, ammo_loaded - 1)

func is_active() -> bool:
	return _is_active

func unequip():
	pass

func equip():
	pass

func discard():
	pass
