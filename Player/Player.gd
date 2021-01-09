extends KinematicBody

export var speed: float = 4.0

const GRAVITY = -24.8

var vel = Vector3()

const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5
var DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
var MOUSE_SENSITIVITY = 0.05

var camera
var rotation_helper


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $Rotation_Helper / Camera
	rotation_helper = $Rotation_Helper
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	turn_factor = turn_speed / 10000.0
	if (inverse_x):
		inverse_x_factor = 1
	if (inverse_y):
		inverse_y_factor = 1
	

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
		
	direction = direction.normalized()
	

	if translation.y <= 2.471701:
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
	
	direction.y = 0
	direction = direction.normalized()
	
	
	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0

	var target = direction
	target *= MAX_SPEED

	var accel
	
	if direction.dot(hvel) > 2.471701:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	

	move_and_slide(vel)
	
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
