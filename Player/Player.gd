extends KinematicBody

export var speed: float = 4.0

const GRAVITY = -24.8

var vel = Vector3()

const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5
var DEACCEL = 16
const MAX_SLOPE_ANGLE = 50
var MOUSE_SENSITIVITY = 0.05
var isCrouching = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
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
<<<<<<< Updated upstream
		
=======
	if Input.is_action_just_pressed("crouch") && is_on_floor():
		if (isCrouching):
			$Camera.translation.y += 1
			$HUD/CenterContainer/Crosshair.rect_scale *= 2
			$HUD/CenterContainer/Crosshair.rect_position.x -= 25
			$HUD/CenterContainer/Crosshair.rect_position.y += 0
			
		else:
			$Camera.translation.y -= 1
			$HUD/CenterContainer/Crosshair.rect_scale *= 0.5
			$HUD/CenterContainer/Crosshair.rect_position.x += 25
			$HUD/CenterContainer/Crosshair.rect_position.y -= 0
		isCrouching = !isCrouching
	
	
>>>>>>> Stashed changes
	direction = direction.normalized()
	
	
	
	var snap = Vector3(0,-0.05,0)
	
<<<<<<< Updated upstream
=======
	if(is_on_floor() && Input.is_action_just_pressed("crouch")):
		if(isCrouching):
			$Camera.translation.y += 1
			$HUD.zoomOut()
		else:
			$Camera.translation.y -= 1
			$HUD.zoomIn()
		isCrouching = !isCrouching
		
>>>>>>> Stashed changes
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
	
	direction.y = 0
	direction = direction.normalized()
	
	#Change the gravity if the player is on the ground and not jumping
	
	if((vel.y < 0.1) && is_on_floor()):
		vel.y = vel.y
	else:
		vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0

	var target = direction
	target *= MAX_SPEED

	var accel
	
	if direction.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z

	if (vel.y > 0.1):
		snap = Vector3(0,0,0)

	move_and_slide_with_snap(vel, snap, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

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
