extends KinematicBody

export var speed: float = 4.0
onready var PlayerStats = $PlayerStats

const GRAVITY = -24.8

var vel = Vector3()

const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5
var DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
var MOUSE_SENSITIVITY = 0.05
var isCrouching = false
var stamina = 100

var is_dead: bool = false

onready var ray = $Camera/RayCast

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
		set_process_input(false)
	
	# Movement
	var aiming = $Camera.transform.basis
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
	
	var snap = Vector3(0,-0.05,0)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
			
	if(Input.is_action_just_pressed("crouch") && is_on_floor()):
		if(isCrouching):
			$Camera.translation.y += 1
			$HUD.zoomOut()
		else:
			$Camera.translation.y -= 1
			$HUD.zoomIn()
		isCrouching = !isCrouching
	
	direction.y = 0
	direction = direction.normalized()
	
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
	
	if(Input.is_action_pressed("sprint") && !isCrouching && (stamina > 0)):
		vel.x *= 1.025
		vel.z *= 1.025
		stamina -= 0.2
	else:
		if(stamina < 100):
			stamina += 0.2
			
#	print(stamina)
	
	if(isCrouching):
		vel.x = vel.x * 0.75
		vel.z = vel.z * 0.75
		
	if(isCrouching):
		$StandingCollisionShape.disabled = true
		$CrouchingCollisionShape.disabled = false
	else:
		$StandingCollisionShape.disabled = false
		$CrouchingCollisionShape.disabled = true
	
	if (vel.y > 0.1):
		snap = Vector3(0,0,0)
	
	move_and_slide_with_snap(vel, snap, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	# Using items/weapons
	var held_weapon = $Camera/WeaponHolder.get_child(0)
	var held_item = $Camera/ItemHolder.get_child(0)
	var use_item_pressed: bool = Input.is_action_pressed("use_item")
	var use_item_alt_pressed: bool = Input.is_action_pressed("use_item_alt")
	var interact_pressed: bool = Input.is_action_just_pressed("interact")
	
	if held_item != null:
		if use_item_pressed or interact_pressed:
			held_item.unequip()
			$Camera/ItemHolder.remove_child(held_item)
			held_item.translation = translation - aiming[2]
			held_item.translation.y += 1
			get_parent().add_child(held_item)
		return
	
	if held_weapon != null:
		held_weapon.ray = ray
		held_weapon.use_item_pressed = use_item_pressed
		held_weapon.use_item_alt_pressed = use_item_alt_pressed
		if held_weapon.is_active:
			return
	
	if interact_pressed:
		ray.force_raycast_update()
		if !ray.is_colliding():
	#			print("asdf")
			return
			
		var obj = ray.get_collider()
		print(obj)
		if obj.translation.distance_to(translation) > 4:
			return
		
		if obj.has_method("interact"):
			obj.interact()
		elif obj.has_method("pick_up"):
			obj.get_parent().remove_child(obj)
			$Camera/ItemHolder.add_child(obj)
			obj.pick_up()




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
	
	$Camera.set_rotation(Vector3(aim_y, aim_x, 0))

## Enemy/hazard interactions ##
func hitboxes() -> Array:
	return $Hitbox.get_children()
