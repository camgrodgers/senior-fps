extends KinematicBody
class_name Player

onready var PlayerStats: Node = $PlayerStats
onready var settings: Settings = get_node("/root/Settings")
onready var signals = get_node("/root/Signals")

var is_dead: bool = false

onready var ray = $CameraHolder/Camera/RayCast
onready	var weapon_holder = $CameraHolder/Camera/WeaponHolder
onready var item_holder = $CameraHolder/Camera/ItemHolder
var held_weapon: HitScanWeapon = null


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$HUD.camera = $CameraHolder
	$HUD.player = self
	signals.connect("recoil", self, "_on_weapon_recoil")
	signals.connect("camera_zoom",self,"_on_zoom_camera")
	signals.connect("camera_unzoom",self,"_on_unzoom_camera")
	for weapon in weapon_holder.get_children():
		weapon.set_ray(ray)
		_unequip_weapon(weapon)
	_equip_weapon(weapon_holder.get_node("Glock18"))
	
	
	$Sound_Player.play_sound($Sound_Player.gun_cock)

func die() -> void:
	is_dead = true
	$HUD.player_dead_message()
	$Danger_Player.stop()
	set_process(false)
	set_physics_process(false)
#	set_process_input(false)
	return

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
		settings.flying = !settings.flying


	if PlayerStats.danger_level >= 100 && !settings.invincibility:
		$Sound_Player.play_sound($Sound_Player.game_over_shot)
		die()
		
	
	# Movement
	if(settings.flying):
		_fly(delta)
	else:
		_process_movement(delta)
	# Using items/weapons
	_process_item_use(delta)
	# Screen shake
	_aim_shake(delta)
	_crosshair_update(delta)
	_process_recoil(delta)
	if not _zoomed:
		$CameraHolder/Camera.fov = settings.fov
	
	if Input.is_action_just_pressed("debug"):
		settings.invincibility = !settings.invincibility

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
var lastFloorYcoord = 0
var fallDie = false

func _fly(delta: float) -> void:
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
func _process_movement(delta: float) -> void:
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
				$StandingCollisionShape.disabled = false
				$CrouchingCollisionShape.disabled = true
				$StandingHitboxes.monitorable = true
				$CrouchingHitboxes.monitorable = false
			else:
				$CameraHolder.translation.y -= 0.7
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
	
	
	if(is_on_floor()):
		lastFloorYcoord = translation.y
		if(fallDie):
			die()
	if((lastFloorYcoord - translation.y) > 12):
		fallDie = true
	
	
	if vel.abs().length() < 0.01:
		return
	
	var snap = Vector3.DOWN if is_on_floor() and vel.y == 0 else Vector3.ZERO
	move_and_slide_with_snap(vel,
		snap,
		Vector3(0, 1, 0), # up direction
		true, # stop on slope. this only partially works.
		4, # max slides
		deg2rad(MAX_SLOPE_ANGLE))
	

# Weapons/item use
func _process_item_use(_delta: float) -> void:
	# Using items/weapons
	var items_in_slots = weapon_holder.get_children()
	if Input.is_action_pressed("slot0"):
		if items_in_slots[0] != null: _switch_to_weapon(items_in_slots[0])
	if Input.is_action_pressed("slot1"):
		if items_in_slots[1] != null: _switch_to_weapon(items_in_slots[1])
	if Input.is_action_pressed("slot2"):
		if items_in_slots[2] != null: _switch_to_weapon(items_in_slots[2])
	if Input.is_action_pressed("slot3"):
		if items_in_slots[3] != null: _switch_to_weapon(items_in_slots[3])
	if Input.is_action_pressed("slot4"):
		if items_in_slots[4] != null: _switch_to_weapon(items_in_slots[4])
	
	var held_item = (
		item_holder.get_child(0) if item_holder.get_child_count() > 0
		else null)
	var use_item_pressed: bool = Input.is_action_pressed("use_item")
	var use_item_alt_pressed: bool = Input.is_action_pressed("use_item_alt")
	var reload_pressed: bool = Input.is_action_pressed("reload")
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
		held_weapon.set_inputs(use_item_pressed,
				use_item_alt_pressed,
				reload_pressed)
		
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
			var loot = obj.interact()
			if loot == null or loot.empty(): 
				return
			held_weapon.ammo_backup += loot["SKS_ammo"]
			
		elif obj.has_method("pick_up"):
			obj.get_parent().remove_child(obj)
			$CameraHolder/Camera/ItemHolder.add_child(obj)
			obj.pick_up()

func add_weapon_ammo(weapon_name: String,
		amount: int,
		enable_weapon: bool = false) -> void:
	var weapon: HitScanWeapon
	if weapon_name == "AK47":
		weapon = $CameraHolder/Camera/WeaponHolder/AK47
	elif weapon_name == "Glock18":
		weapon = $CameraHolder/Camera/WeaponHolder/Glock18
	else:
		return
	weapon.add_ammo(amount, enable_weapon)

func _equip_weapon(weapon: HitScanWeapon) -> void:
	if not weapon.enabled:
		return
	weapon.visible = true
	weapon.set_physics_process(true)
	held_weapon = weapon

func _unequip_weapon(weapon: HitScanWeapon) -> void:
	if weapon == null:
		return
	weapon.visible = false
	weapon.set_physics_process(false)
	held_weapon = null

func _switch_to_weapon(weapon: HitScanWeapon) -> void:
	if not weapon.enabled:
		return
	_unequip_weapon(held_weapon)
	_equip_weapon(weapon)


# Camera motion
var aim_x: float = 0.00
var aim_y: float = 0.00

var aim_shake_width: float = .005
var aim_shake_speed: float = 5
var _aim_shake_counter: float = 0.5
var _zoomed: bool = false

func _aim_shake(delta: float) -> void:
	if _aim_shake_counter == INF:
		_aim_shake_counter = 0
	var offset_x = (cos(_aim_shake_counter)
			* (aim_shake_width + (vel.abs().length() / 800))
			)
	_aim_shake_counter += delta * aim_shake_speed

	ray.set_rotation(Vector3(0, offset_x, 0))

var _goal_recoil: float = 0
var _recoil: float = 0
const RECOIL_MAX_ANGLE: float = 15.0

func _on_zoom_camera(amount: int) -> void:
	$CameraHolder/Camera.fov = amount
	_zoomed = true

func _on_unzoom_camera() -> void:
	$CameraHolder/Camera.fov = settings.fov
	_zoomed = false
	
func _on_weapon_recoil(force: float) -> void:
	_goal_recoil = clamp(_goal_recoil + force, 0, RECOIL_MAX_ANGLE)

func _process_recoil(delta) -> void:
	var camera = $CameraHolder/Camera
	camera.rotation_degrees = camera.rotation_degrees.linear_interpolate(
			Vector3(_goal_recoil, 0,  0),
			delta * 10
			)
	_goal_recoil = clamp(_goal_recoil - (delta * 25), 0, RECOIL_MAX_ANGLE)

func _crosshair_update(delta:float) -> void:
	# Animated Crosshair
	$HUD/AnimatedCrosshair.goal_width = 10 + (vel.abs().length() * 1.5)
	
	# Laser Point
	ray.force_raycast_update()
	if !ray.is_colliding():
		$CameraHolder/LaserPoint.translation = Vector3(0, 0, 0)
		return

	var point = ray.get_collision_point()
	$CameraHolder/LaserPoint.global_transform.origin = point

func _input(event: InputEvent) -> void:
	if !event is InputEventMouseMotion:
		return
	
	var inverse_x_factor: int = 1 if settings.inverse_x else -1
	var inverse_y_factor: int = 1 if settings.inverse_y else -1
	var turn_speed: float = (settings.mouse_sensitivity / 
		(50 if not _zoomed else 100))
	
	aim_x += event.relative.x * turn_speed * inverse_x_factor
	aim_y += event.relative.y * turn_speed * inverse_y_factor
	aim_y = clamp(aim_y, -89.9, 89.9)
	
	$CameraHolder.set_rotation(Vector3(deg2rad(aim_y), deg2rad(aim_x), 0))

## Enemy/hazard interactions ##
func hitboxes() -> Array:
	if is_crouching:
		return $CrouchingHitboxes.get_children()
	else:
		return $StandingHitboxes.get_children()
		
