extends Enemy

func _init():
	ENEMY_RANGE = 40.0
	MINIMUM_RANGE = 10.0
	WOUNDED_RANGE = 30.0
	
func _ready():
	pass

func rate_of_danger_increase() -> float:
	var player_speed: float = player.vel.length()
	
	if not world_state["can_see_player"]:
		return 0.0
	
	var rate: float = 0
	if player_distance > 150:
		rate = 0
	elif player_distance > 100:
		rate = 2
	elif player_distance > 50:
		rate = 10
	elif player_distance > 30:
		rate = 15
	elif player_distance > 10:
		rate = 20
	else:
		rate = 30
	
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
