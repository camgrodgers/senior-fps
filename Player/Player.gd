extends KinematicBody

onready var PlayerStats: Node = $PlayerStats

var is_dead: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	turn_factor = turn_speed / 10000.0
	if (inverse_x):
		inverse_x_factor = 1
	if (inverse_y):
		inverse_y_factor = 1

func _physics_process(delta):
	if PlayerStats.danger_level >= 100:
		is_dead = true
		$HUD.player_dead_message()
		set_process(false)
		set_physics_process(false)
#		set_process_input(false)
		return
	
	# Movement
	process_movement(delta)
	# Using items/weapons
	process_item_use(delta)
	# Screen shake
	screen_shake(delta)

# Movement
const GRAVITY: float = -24.8

var vel: Vector3 = Vector3()

const MAX_SPEED: int = 20
const AIR_CONTROL_SPEED: int = 5
const JUMP_HEIGHT: int = 18
const ACCEL: float = 4.5
const DEACCEL: float = 16.0
const MAX_SLOPE_ANGLE: int = 40

#enum PlayerStance{CROUCHING, STANDING}
#var stance: int = PlayerStance.STANDING

var is_crouching = false
var stamina = 100

func process_movement(delta: float) -> void:
	var aiming: Basis = $CameraHolder.transform.basis
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
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_HEIGHT
	
	if(Input.is_action_just_pressed("crouch") && is_on_floor()):
		if(is_crouching):
			$CameraHolder.translation.y += 1
			$HUD.zoomOut()
		else:
			$CameraHolder.translation.y -= 1
			$HUD.zoomIn()
		is_crouching = !is_crouching
	
	direction.y = 0
	direction = direction.normalized()
	
	if((vel.y < 0.1) && is_on_floor()):
		vel.y = 0
	else:
		vel.y += delta * GRAVITY
	
	var hvel: Vector3 = vel
	hvel.y = 0

	var target: Vector3 = direction
	if (is_on_floor()):
		target *= MAX_SPEED
	else:
		target *= AIR_CONTROL_SPEED
		target += hvel

	var accel: float = ACCEL if direction.dot(hvel) > 0 else DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	if(Input.is_action_pressed("sprint") && !is_crouching && (stamina > 0)):
		vel.x *= 1.025
		vel.z *= 1.025
		stamina -= 0.2
	else:
		if(stamina < 100):
			stamina += 0.2
			
	
	if(is_crouching):
		vel.x = vel.x * 0.75
		vel.z = vel.z * 0.75
		
	if(is_crouching):
		$StandingCollisionShape.disabled = true
		$CrouchingCollisionShape.disabled = false
	else:
		$StandingCollisionShape.disabled = false
		$CrouchingCollisionShape.disabled = true
	
	print(vel)
	print(is_on_floor())
	var snap = Vector3.DOWN if is_on_floor() and vel.y == 0 else Vector3.ZERO
	move_and_slide_with_snap(vel, snap, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

# Weapons/item use
func process_item_use(_delta: float) -> void:
	if Input.is_action_pressed("use_item_alt"):
		$CameraHolder/Camera/ItemHolder.visible = true
	else:
		$CameraHolder/Camera/ItemHolder.visible = false

	if Input.is_action_just_pressed("use_item"):
		if not Input.is_action_pressed("use_item_alt"):
			return
		
		var ray: RayCast = $CameraHolder/Camera/RayCast
		
		ray.force_raycast_update()
		if !ray.is_colliding():
#			print("asdf")
			return
			
		var obj = ray.get_collider()
		print(obj)
		if obj.has_method("take_damage"):
			obj.take_damage()

# Camera motion
export var turn_speed: int = 50
export var inverse_x: bool = false
export var inverse_y: bool = false

var aim_x: float = 0.00
var aim_y: float = 0.00

var turn_factor: float
var inverse_x_factor: int = -1
var inverse_y_factor: int = -1

var screen_shake_width: float = .005
var screen_shake_counter: float = 0

func screen_shake(delta: float) -> void:
	if screen_shake_counter == INF:
		screen_shake_counter = 0
	var offset_x = sin(screen_shake_counter) * screen_shake_width
	screen_shake_counter += delta * 1
	$CameraHolder/Camera.set_rotation(Vector3(0, offset_x, 0))

func _input(event: InputEvent) -> void:
	if !event is InputEventMouseMotion:
		return
	
	aim_x += event.relative.x * turn_factor * inverse_x_factor
	aim_y += event.relative.y * turn_factor * inverse_y_factor
	aim_y = clamp(aim_y, -1.5, 1.5)
	
	$CameraHolder.set_rotation(Vector3(aim_y, aim_x, 0))

## Enemy/hazard interactions ##
func hitboxes() -> Array:
	return $Hitboxes.get_children()
