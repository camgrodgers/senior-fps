extends KinematicBody

export var speed: float = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	turn_factor = turn_speed / 10000.0
	if (inverse_x):
		inverse_x_factor = 1
	if (inverse_y):
		inverse_y_factor = 1

var isGoingUp = false
var isGoingDown = false


func _physics_process(delta):
	# Movement
	var aiming = transform.basis
	var direction: Vector3 = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		direction -= aiming[2]
	if Input.is_action_pressed("move_backward"):
		direction += aiming[2]
	if Input.is_action_pressed("move_right"):
		direction += aiming[0]
	if Input.is_action_pressed("move_left"):
		direction -= aiming[0]
		
	#Controlling Jumps
	#If the space is Pressed
	if Input.is_action_just_pressed("jump"):
		print("It is hitting the jump function")
		isGoingUp = true
		isGoingDown = false
		
	#Slowly go Up
	if(isGoingUp):
		print("It is increasing the direciton")
		direction.y = 20
	#Slowly go Down
	if(isGoingDown):
		print("It is decreasing the direction")
		direction.y = -20		
	#If it gets to bottom of jump
	if((translation.y <= 2.75) && isGoingDown):
		print("It has reached the bottom of the jump")
		isGoingUp = false
		isGoingDown = false
		translation.y = 2.471701
		direction.y = 0
	#If it gets to top of jump
	if(translation.y > 12):
		print("It has reached the top of the jump")
		isGoingUp = false
		isGoingDown = true
		
	if(!isGoingUp && !isGoingDown):
		translation.y = 2.741701
		
	if(translation.y < 2.741701):
		translation.y = 2.741701
		
	print(translation.x)
	
	#Problem: When the player is in the air, it will follow his y direction up to infinity....
	#Regardless of the directions.
	#Solution: When building new translation coordinates, I need to disable camera from having any factor
	#x, y direction are paused for some reason during the jump.... Perhaps they should be scaled accordingly during a jump....
	
	if(isGoingUp || isGoingDown):
		direction.x *= 25
		direction.z *= 25
	
	direction = direction.normalized()
	direction = direction * 8
	move_and_slide(direction)
	
	# Using items/weapons
	if Input.is_action_just_pressed("use_item"):
		var ray: RayCast = $Camera/RayCast
		
		ray.force_raycast_update()
		if !ray.is_colliding():
			return
			
		var obj = ray.get_collider()
		print(obj)
		if obj.has_method("take_damage"):
			obj.take_damage()

# Camera motion
export var turn_speed = 50
export var inverse_x = false
export var inverse_y = false

var aim_x = 0.00
var aim_y = 0.00

var turn_factor
var inverse_x_factor = -1
var inverse_y_factor = -1


func _input(event):
	if !event is InputEventMouseMotion:
		return
	
	aim_x += event.relative.x * turn_factor * inverse_x_factor
	aim_y += event.relative.y * turn_factor * inverse_y_factor
	aim_y = clamp(aim_y, -1.5, 1.5)
	
	set_rotation(Vector3(aim_y, aim_x, 0))
