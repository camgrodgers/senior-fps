extends CSGCombiner


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ray: RayCast
onready var timer = $Timer


func _physics_process(delta):
	if Input.is_action_pressed("use_item_alt"):
		self.visible = true
	else:
		self.visible = false
		
	if Input.is_action_just_pressed("use_item"):
		if not Input.is_action_pressed("use_item_alt"):
			return
		
		
		ray.force_raycast_update()
		if !ray.is_colliding():
#			print("asdf")
			return
			
		var obj = ray.get_collider()
		print(obj)
		if obj.has_method("take_damage"):
			obj.take_damage()



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
