extends Enemy

var enemy_owner = null
var explosion_started = false
var countdown_started = false
func _init():
	MAX_HP = 3.0
	ENEMY_RANGE = 2.5
	DAMAGE_MULTIPLIER = 0.0
	current_damage_mult = DAMAGE_MULTIPLIER
	world_state["has_target"] = true
	world_state["patrolling"] = false
func _ready():
	$Enemy_audio_player.movement = preload("res://Sounds/Drone_movement.wav")
	$Enemy_audio_player.enemy_shot = preload("res://Sounds/Explosion.wav")
	$Enemy_audio_player.destruction_alert = preload("res://Sounds/beeps.wav")
	replan_actions()
	

func _process(delta):
	if not $Enemy_audio_player.playing():
		$Enemy_audio_player.play_sound($Enemy_audio_player.movement)
func take_damage(damage: float) -> void:

	$CSGCombiner.get_node("CSGBox" + str(int(damage_taken))).visible = false
	damage_taken += damage
	
	if damage_taken < MAX_HP:
		$CSGCombiner.get_node("CSGBox" + str(int(damage_taken))).visible = true
		return
	var corpse_scn: Resource = preload("res://Enemies/Enemy_Drone_Corpse.tscn")
	var corpse = corpse_scn.instance()
	corpse.transform = self.transform
	enemy_owner.drone_dead = true
	signals.emit_signal("temporary_object_spawned", corpse)
	clear_node_data()
	self.queue_free()

func explode():
	if not explosion_started:
		$Enemy_audio_player.play_sound($Enemy_audio_player.enemy_shot)
		explosion_started = true

func beep():
	if not countdown_started:
		$Enemy_audio_player.play_sound($Enemy_audio_player.destruction_alert)
		countdown_started = true
