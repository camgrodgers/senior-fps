extends Enemy

func _init():
	MAX_HP = 3.0
	ENEMY_RANGE = 15.0
	_shoot_interval = 4.0
	DAMAGE_MULTIPLIER = 1.5
	MINIMUM_RANGE = 0
	
func _ready():
	$Enemy_audio_player.enemy_shot = preload("res://Sounds/Shotgun_shot.wav")

func rate_of_danger_increase() -> float:
	var player_speed: float = player.vel.length()
	
	if not world_state["can_see_player"]:
		return 0.0
	
	var rate: float = 0
	if player_distance > 80:
		rate = 0
	elif player_distance > 50:
		rate = 0
	elif player_distance > 30:
		rate = 6
	elif player_distance > 20:
		rate = 15
	elif player_distance > 10:
		rate = 30
	else:
		rate = 40
	
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
