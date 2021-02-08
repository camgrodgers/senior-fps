extends CSGCombiner


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ray: RayCast
onready var timer = $Timer

var use_item_alt_pressed: bool = false
var use_item_pressed: bool = false
var is_active: bool = false


func _physics_process(delta):
	is_active = false
	
	if use_item_alt_pressed:
		is_active = true
		self.visible = true
	else:
		self.visible = false
		
	if use_item_pressed:
		if not use_item_alt_pressed:
			return
		
		ray.force_raycast_update()
		if !ray.is_colliding():
#			print("asdf")
			return
			
		var obj = ray.get_collider()
		print(obj)
		if obj.has_method("take_damage"):
			obj.take_damage()
		if obj is RigidBody:
			var force = global_transform.origin.direction_to(obj.translation)
			obj.apply_central_impulse(force)

func unequip():
	self.queue_free()

func equip():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
