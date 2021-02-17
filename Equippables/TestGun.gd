extends CSGCombiner

var ray: RayCast
onready var timer: Timer = $Timer

var use_item_alt_pressed: bool = false
var use_item_pressed: bool = false
var is_active: bool = false
export var raised: bool = true
export var chambering: float = 0.0

func _physics_process(delta):
	chambering = clamp(chambering - delta, 0, 0.15)
	is_active = false
	
	if use_item_alt_pressed:
		is_active = true
		if not raised:
			$AnimationPlayer.play("Raise")
	else:
		if raised:
			$AnimationPlayer.play_backwards("Raise")
		
	if use_item_pressed:
		if not (use_item_alt_pressed and raised and chambering == 0):
#			print("didn't fire")
			return
#		print("fired")
		
		$AnimationPlayer.play("Fire")
		chambering = 0.15
		ray.force_raycast_update()
		if !ray.is_colliding():
#			print("asdf")
			return
			
		var obj = ray.get_collider()
#		print(obj)
		if obj.has_method("take_damage"):
			obj.take_damage()
		if obj is RigidBody:
			var force = global_transform.origin.direction_to(obj.translation) / 4
			obj.apply_central_impulse(force)

func unequip():
	self.queue_free()

func equip():
	pass

func _ready():
	$AnimationPlayer.play_backwards("Raise")
