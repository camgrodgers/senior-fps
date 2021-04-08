extends Enemy

var enemy_owner = null
var explosion_started = false
var countdown_started = false
var powering_down = false
func _init():
	MAX_HP = 3.0
	ENEMY_RANGE = 3.0
	DAMAGE_MULTIPLIER = 0.0
	current_damage_mult = DAMAGE_MULTIPLIER
	world_state["has_target"] = true
	world_state["patrolling"] = false

func _ready():
	$Enemy_audio_player.movement = preload("res://Sounds/Drone_movement.wav")
	$Enemy_audio_player.enemy_shot = preload("res://Sounds/Explosion.wav")
	$Enemy_audio_player.destruction_alert = preload("res://Sounds/beeps.wav")
	$Enemy_audio_player.power_down = preload("res://Sounds/Power_Down.wav")
	replan_actions()
	

func _process(delta):
	if(!enemy_owner.get_ref()):
		power_down()
		return
	if not $Enemy_audio_player.playing():
		$Enemy_audio_player.play_sound($Enemy_audio_player.movement)
func take_damage(damage: float) -> void:

	$CSGCombiner.get_node("CSGCylinder" + str(int(damage_taken))).visible = false
	damage_taken += damage / 3
	
	if damage_taken < MAX_HP:
		$CSGCombiner.get_node("CSGCylinder" + str(int(damage_taken))).visible = true
		return
	var corpse_scn: Resource = preload("res://Enemies/Enemy_Drone_Corpse.tscn")
	var corpse = corpse_scn.instance()
	corpse.transform = self.transform
	signals.emit_signal("temporary_object_spawned", corpse)
	clear_node_data()
	self.queue_free()

func explode():
	if not explosion_started:
		$CSGCombiner/CSGSphere.visible = true
		$Enemy_audio_player.play_sound($Enemy_audio_player.enemy_shot)
		explosion_started = true

func beep():
	if not countdown_started:
		$Enemy_audio_player.play_sound($Enemy_audio_player.destruction_alert)
		countdown_started = true

func power_down():
	if not powering_down:
		$Enemy_audio_player.play_sound($Enemy_audio_player.power_down)
		powering_down = true
		if action_plan[action_index] == $GOAP_Planner/Actions/action_get_in_range:
			action_index += 1
	if not $Enemy_audio_player.playing():
		var corpse_scn: Resource = preload("res://Enemies/Enemy_Drone_Corpse.tscn")
		var corpse = corpse_scn.instance()
		corpse.transform = self.transform
		signals.emit_signal("temporary_object_spawned", corpse)
		clear_node_data()
		self.queue_free()
	return

func rate_of_danger_increase() -> float:
	var player_speed: float = player.vel.length()
	
	if not world_state["can_see_player"]:
		return 0.0
	
	var rate: float = 0

	
	if player_distance > 10:
		rate = 0
	elif player_distance > 5:
		rate = 20
	else:
		rate = 45
	
	rate = rate * current_damage_mult
	
	var speed_factor: float = 1
	if player_speed < 2:
		speed_factor = 2
	elif player_speed > 15:
		speed_factor = 0.75
		#TODO: add a timer or something for the speed factor so it doesn't immediately go up when 
		#you change directions
		pass
	
	rate *= speed_factor
	return rate

func move_along_path(delta: float, lookat: bool = false) -> void:
	if path == null or path.empty():
		print("null or empty path")
		return
	
	var moving = ENEMY_SPEED * delta
	var to = path[0]
	
	while translation.distance_to(to) < moving:
		path.pop_front()
		if path.empty():
			return
		to = path[0]
	var distance = translation.distance_to(to)
	var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
	look_at(global_transform.origin + velocity, Vector3.UP)
	translation = translation.linear_interpolate(to, moving/distance)
