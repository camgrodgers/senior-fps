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
	signals.connect("level_completed", self, "_on_level_completed")
	for weapon in weapon_holder.get_children():
		weapon.set_ray(ray)
		_unequip_weapon(weapon)
	_equip_weapon(weapon_holder.get_node("Glock18"))
	
	
	$Sound_Player.play_sound($Sound_Player.gun_cock)
func _on_level_completed(end_level: bool) -> void:
	if end_level:
		disable_inputs()
	var message := "You beat the level!"
	if end_level: message += ' Press "space" to continue.' 
	signals.emit_signal("popup_message", message)
	yield(get_tree().create_timer(5.0), "timeout")
	signals.emit_signal("hide_popup_message")

func disable_inputs() -> void:
	$Danger_Player.stop()
#	if held_weapon != null:
#		held_weapon.set_inputs(false,
#				false,
#				false)
	set_process(false)
	set_physics_process(false)
#	set_process_input(false)

func die() -> void:
	is_dead = true
#	$HUD.player_dead_message()
	signals.emit_signal("popup_message", 'You are dead. Press "space" to reload.')
	disable_inputs()
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

func _fly(delta: float) -> void:
	var aiming: Basis = $CameraHolder.transform.basis
	var direction: Vector3 = Vector3()
	var target_speed: float = MAX_WALK_SPEED
	
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
		target_speed *= 1.5
	
	var target = direction * target_speed
	vel = vel.linear_interpolate(target, 5 * delta)
	
	move_and_slide(vel)

# Movement
const MAX_CROUCH_SPEED: float = 6.0
const MAX_WALK_SPEED: float = 11.0
const MAX_SPRINT_SPEED: float = 18.0
const CROUCH_ACCEL: float = 50.0
const WALK_ACCEL: float = 80.0
const SPRINT_ACCEL := 130.0
const AIR_ACCEL: float = 17.0
const JUMP_SPEED := 13.0
const FRICTION_RATE := 8.0
const GRAVITY := 40.0
const FALL_DEATH_HEIGHT := 15.0
const MAX_SLOPE_ANGLE: int = 40

var vel: Vector3 = Vector3()
var _max_speed = 0
var _is_crouching: bool = false
var _last_floor_y_coord: float = translation.y

# This was initially intended to work as Quake/HL style movement as 
# described here:
# https://steamcommunity.com/sharedfiles/filedetails/?id=184184420
# However, this code uses vector addition instead of vector projection,
# which I believe should prevent Quake/HL-style bunnyhopping.
func _process_movement(delta: float) -> void:
	var aiming: Basis = $CameraHolder.transform.basis
	var accel: Vector3 = Vector3()
	var accel_magnitude := 0.0
	var horizontal_vel := vel
	horizontal_vel.y = 0
	var curr_speed := horizontal_vel.length()
	
	if Input.is_action_pressed("move_forward"):
		accel -= aiming.z
	if Input.is_action_pressed("move_backward"):
		accel += aiming.z
	if Input.is_action_pressed("move_right"):
		accel += aiming.x
	if Input.is_action_pressed("move_left"):
		accel -= aiming.x
	accel.y = 0
	accel = accel.normalized()
	
	if Input.is_action_just_pressed("crouch"):
		_toggle_crouch()
	
	if is_on_floor():
		# Determine whether player will die from falling
		if (_last_floor_y_coord - translation.y > FALL_DEATH_HEIGHT
				and not settings.invincibility):
			die()
		_last_floor_y_coord = translation.y
		
		vel.y = 0
		if _is_crouching:
			accel_magnitude = CROUCH_ACCEL
			_max_speed = MAX_CROUCH_SPEED
		elif Input.is_action_pressed("sprint"):
			accel_magnitude = SPRINT_ACCEL
			_max_speed = MAX_SPRINT_SPEED
		else:
			accel_magnitude = WALK_ACCEL
			_max_speed = MAX_WALK_SPEED
		
		# Apply friction using classic friction formula
		vel -= FRICTION_RATE * vel * delta
		
		if Input.is_action_just_pressed("jump"):
			vel.y += JUMP_SPEED if not _is_crouching else JUMP_SPEED / 1.5
	else:
		accel_magnitude = AIR_ACCEL
		vel.y -= GRAVITY * delta
	
	# If acceleration vector for next frame + current velocity has a magnitude
	# greater than the max speed, acceleration magnitude will approach zero.
	# This sets a hard limit on air speed, preventing extreme bunnyhopping.
	var new_speed = ((accel * accel_magnitude * delta) + horizontal_vel).length()
	if new_speed > curr_speed and new_speed > _max_speed:
		accel_magnitude = _max_speed - curr_speed
	
	vel += accel * accel_magnitude * delta
	
	if vel.length() < 0.01:
		return
	
	var snap = Vector3.DOWN if is_on_floor() and vel.y == 0 else Vector3.ZERO
	move_and_slide_with_snap(vel,
		snap,
		Vector3(0, 1, 0), # up direction
		true, # stop on slope. this only partially works.
		4, # max slides
		deg2rad(MAX_SLOPE_ANGLE))

func _toggle_crouch():
	if _is_crouching:
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
	_is_crouching = !_is_crouching

# Weapons/item use
func _process_item_use(_delta: float) -> void:
	# Using items/weapons
	var items_in_slots = weapon_holder.get_children()
	if not (held_weapon == null or held_weapon.is_active()):
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
	elif weapon_name == "SNIPER":
		weapon = $CameraHolder/Camera/WeaponHolder/SNIPER
	else:
		return
	var just_enabled := false
	if enable_weapon and not weapon.enabled:
		just_enabled = true
	weapon.add_ammo(amount, enable_weapon)
	if just_enabled: _switch_to_weapon(weapon)

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
	signals.emit_signal("camera_unzoom")

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

	var point: Vector3 = ray.get_collision_point()
	var distance = point.distance_to(self.global_transform.origin)
	$CameraHolder/LaserPoint.radius = range_lerp(
		distance, 0, (250 if not _zoomed else 500), 0.015, 1
	)
	$CameraHolder/LaserPoint.global_transform.origin = point

func _input(event: InputEvent) -> void:
	if !event is InputEventMouseMotion:
		return
	
	var inverse_x_factor: int = 1 if settings.inverse_x else -1
	var inverse_y_factor: int = 1 if settings.inverse_y else -1
	var turn_speed: float = (settings.mouse_sensitivity / 
		(50 if not _zoomed else 140))
	
	aim_x += event.relative.x * turn_speed * inverse_x_factor
	aim_y += event.relative.y * turn_speed * inverse_y_factor
	aim_y = clamp(aim_y, -89.9, 89.9)
	
	$CameraHolder.set_rotation(Vector3(deg2rad(aim_y), deg2rad(aim_x), 0))

## Enemy/hazard interactions ##
func hitboxes() -> Array:
	if _is_crouching:
		return $CrouchingHitboxes.get_children()
	else:
		return $StandingHitboxes.get_children()
		
