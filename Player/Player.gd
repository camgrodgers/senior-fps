extends KinematicBody
class_name Player

onready var PlayerStats: Node = $PlayerStats

var is_dead: bool = false
var debug: bool = false
var devmode: bool = false

var playerAltLevel = 1

onready var ray = $CameraHolder/Camera/RayCast
onready	var weapon_holder = $CameraHolder/Camera/WeaponHolder
onready var item_holder = $CameraHolder/Camera/ItemHolder

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$HUD.camera = $CameraHolder
	$HUD.player = self
	$CameraHolder/Camera/WeaponHolder/SKS.connect(
			"recoil",
			self,
			"_on_weapon_recoil")
	
	turn_factor = turn_speed / 10000.0
	if (inverse_x):
		inverse_x_factor = 1
	if (inverse_y):
		inverse_y_factor = 1
	
	$Sound_Player.play_sound($Sound_Player.gun_cock)
func _process(delta) -> void:
	$Danger_Player.volume_db = -50 + PlayerStats.danger_level / 2
	if not $Danger_Player.playing:
		$Danger_Player.play()
	if ((vel.abs().length() > 0.5)
			and is_on_floor()
			and not is_dead):
		if not $Footsteps.playing:
			$Footsteps.play()
	else:
		$Footsteps.stop()

func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("flymode"):
		devmode = !devmode
		
	if PlayerStats.danger_level >= 100 && !debug:
		is_dead = true
		$HUD.player_dead_message()
		$Danger_Player.stop()
		$Sound_Player.play_sound($Sound_Player.game_over_shot)
		set_process(false)
		set_physics_process(false)
#		set_process_input(false)
		return
	
	# Movement
	if(devmode):
		fly(delta)
	else:
		process_movement(delta)
	# Using items/weapons
	process_item_use(delta)
	# Screen shake
#	screen_shake(delta)
	crosshair_update(delta)
	_process_recoil(delta)
	
	if Input.is_action_just_pressed("debug"):
		debug = !debug

# Movement
const GRAVITY: float = -40.0

var vel: Vector3 = Vector3()

const WALK_SPEED: int = 10
const AIR_CONTROL_SPEED: int = 5
const JUMP_HEIGHT: int = 15
const ACCEL: float = 4.5
const DEACCEL: float = 16.0
const MAX_SLOPE_ANGLE: int = 40

#enum PlayerStance{CROUCHING, STANDING}
#var stance: int = PlayerStance.STANDING

var is_crouching: bool = false
var stamina: float = 100.0

func fly(delta: float) -> void:
	var aiming: Basis = $CameraHolder.transform.basis
	var direction: Vector3 = Vector3()
	var target_speed: float = WALK_SPEED
	
	if Input.is_action_pressed("move_forward"):
		direction -= aiming[2]
	if Input.is_action_pressed("move_backward"):
		direction += aiming[2]
	if Input.is_action_pressed("move_right"):
		direction += aiming[0]
	if Input.is_action_pressed("move_left"):
		direction -= aiming[0]
	

	direction = direction.normalized()
	
	if Input.is_action_pressed("sprint"):
		target_speed *= 1.25
	
	var target = direction * target_speed
	
	vel = vel.linear_interpolate(target, ACCEL * delta)

	move_and_slide(vel)
	
	
# NOTE: Much of movement code is boilerplate and based on tutorials
#		such as this one: 
#		https://docs.godotengine.org/en/3.2/tutorials/3d/fps_tutorial/part_one.html#making-the-fps-movement-logic
func process_movement(delta: float) -> void:
	var aiming: Basis = $CameraHolder.transform.basis
	var direction: Vector3 = Vector3()
	var target_speed: float = WALK_SPEED
	
	if Input.is_action_pressed("move_forward"):
		direction -= aiming.z
	if Input.is_action_pressed("move_backward"):
		direction += aiming.z
	if Input.is_action_pressed("move_right"):
		direction += aiming.x
	if Input.is_action_pressed("move_left"):
		direction -= aiming.x
	
	direction.y = 0
	direction = direction.normalized()
	
	var hvel: Vector3 = vel
	hvel.y = 0
	var target: Vector3 = direction
	var accel: float = ACCEL if direction.dot(hvel) > 0 else DEACCEL

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_HEIGHT
		else:
			vel.y = 0
		
		if Input.is_action_just_pressed("crouch"):
			if is_crouching:
				$CameraHolder.translation.y += 0.7
				$HUD.zoomOut()
				$StandingCollisionShape.disabled = false
				$CrouchingCollisionShape.disabled = true
				$StandingHitboxes.monitorable = true
				$CrouchingHitboxes.monitorable = false
			else:
				$CameraHolder.translation.y -= 0.7
				$HUD.zoomIn()
				$StandingCollisionShape.disabled = true
				$CrouchingCollisionShape.disabled = false
				$StandingHitboxes.monitorable = false
				$CrouchingHitboxes.monitorable = true
			is_crouching = !is_crouching
		if is_crouching:
			target_speed *= 0.5
		if (Input.is_action_pressed("sprint")
				and stamina > 0
				and not is_crouching):
			target_speed *= 1.75
			accel *= 1.5
			stamina -= 10 * delta
		elif stamina < 100:
			stamina = clamp(stamina + 20 * delta, 0, 100)
		
		target *= target_speed
	else:
		vel.y += delta * GRAVITY
		target = hvel
#		target *= AIR_CONTROL_SPEED
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	var snap = Vector3.DOWN if is_on_floor() and vel.y == 0 else Vector3.ZERO
	move_and_slide_with_snap(vel,
		snap,
		Vector3(0, 1, 0), # up direction
		false, # stop on slope
		4, # max slides
		deg2rad(MAX_SLOPE_ANGLE))
	

# Weapons/item use
func process_item_use(_delta: float) -> void:
	# Using items/weapons
	var held_weapon: HitScanWeapon = (
		weapon_holder.get_child(0) if weapon_holder.get_child_count() > 0
		else null)
	var held_item = (
		item_holder.get_child(0) if item_holder.get_child_count() > 0
		else null)
	var use_item_pressed: bool = Input.is_action_pressed("use_item")
	var use_item_alt_pressed: bool = Input.is_action_pressed("use_item_alt")
	var interact_pressed: bool = Input.is_action_just_pressed("interact")
	var aiming: Basis = $CameraHolder.transform.basis
	
	if held_item != null:
		if use_item_pressed or interact_pressed:
			held_item.unequip()
			$CameraHolder/Camera/ItemHolder.remove_child(held_item)
			held_item.translation = translation - aiming[2]
			held_item.translation.y += 1
			get_parent().add_child(held_item)
		return
	
	if held_weapon != null:
		held_weapon.set_ray(ray)
		held_weapon.set_inputs(use_item_pressed, use_item_alt_pressed)
		
		if held_weapon.is_active():
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
			$CameraHolder/Camera/ItemHolder.add_child(obj)
			obj.pick_up()




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
var screen_shake_counter: float = 0.5

var _min = 0
var _max = 0
func screen_shake(delta: float) -> void:
	if screen_shake_counter == INF:
		screen_shake_counter = 0
	var offset_x = (cos(screen_shake_counter) * screen_shake_width) #+ (screen_shake_width / 2)
	screen_shake_counter += delta * 2
	if offset_x < _min: _min = offset_x
	if offset_x > _max: _max = offset_x
#	print(_min)
#	print(_max)
#	ray.rotation_degrees = ray.rotation_degrees.linear_interpolate(Vector3(0, offset_x, 0), 1)
	ray.set_rotation(Vector3(0, offset_x, 0))

var _goal_recoil: float = 0
var _recoil: float = 0
const RECOIL_MAX_ANGLE: float = 15.0

func _on_weapon_recoil(force: float) -> void:
	_goal_recoil = clamp(_goal_recoil + force, 0, RECOIL_MAX_ANGLE)

func _process_recoil(delta) -> void:
	var camera = $CameraHolder/Camera
	camera.rotation_degrees = camera.rotation_degrees.linear_interpolate(
			Vector3(_goal_recoil, 0,  0),
			delta * 10
			)
	_goal_recoil = clamp(_goal_recoil - (delta * 25), 0, RECOIL_MAX_ANGLE)

func crosshair_update(delta:float) -> void:
	$HUD/AnimatedCrosshair.goal_width = 10 + (vel.abs().length() * 1.5)
#	ray.force_raycast_update()
#	if !ray.is_colliding():
##		$HUD.crosshair_coordinates = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
#		return
#
#	var point = ray.get_collision_point()
#	$HUD.crosshair_coordinates = $CameraHolder/Camera.unproject_position(point)

func _input(event: InputEvent) -> void:
	if !event is InputEventMouseMotion:
		return
	
	aim_x += event.relative.x * turn_factor * inverse_x_factor
	aim_y += event.relative.y * turn_factor * inverse_y_factor
	aim_y = clamp(aim_y, -1.5, 1.5)
	
	$CameraHolder.set_rotation(Vector3(aim_y, aim_x, 0))

## Enemy/hazard interactions ##
func hitboxes() -> Array:
	if is_crouching:
		return $CrouchingHitboxes.get_children()
	else:
		return $StandingHitboxes.get_children()
		
