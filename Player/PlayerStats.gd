extends Node

var danger_level: float = 0
var danger_decrease_acceleration: float = 0.1
# NOTE: This could be changed to a per-enemy value
var danger_decrease_velocity: float = 0

func _physics_process(delta):
	danger_update(delta)

# Handles enemy and player data
func danger_update(delta):
	danger_level = 0
	
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	
	for e in enemies:
		if e.can_see_player:
			danger_decrease_velocity = 0
			break
	
	for e in enemies:
		var rate = rate_of_danger_increase(e) if e.can_see_player else 0
		e.player_danger = clamp(e.player_danger + (rate * delta), 0, 100)
#		print("rate: {%f} danger: {%f}" % [rate, e.player_danger])
		if danger_decrease_velocity != 0:
			e.player_danger -= (danger_decrease_velocity / enemies.size())
		danger_level += e.player_danger
	
	danger_level = clamp(danger_level, 0, 100)
	danger_decrease_velocity += (danger_decrease_acceleration * delta)
	
	if danger_level == 0:
		danger_decrease_velocity = 0

func rate_of_danger_increase(enemy) -> float:
	var player_distance: float = enemy.player_distance
	var player_speed: float = get_parent().vel.abs().length()
	
	var rate: float = 0
	if player_distance > 50:
		rate = 0
	elif player_distance > 30:
		rate = 5
	elif player_distance > 20:
		rate = 10
	elif player_distance > 10:
		rate = 15
	elif player_distance > 5:
		rate = 20
	else:
		rate = 30
	
	var speed_factor: float = 1
	if player_speed < 4:
		speed_factor = 3
	else:
		# speed_factor should be <1 when player is sprinting or dodging and jumping around
		#add a timer or something for the speed factor so it doesn't immediately go up when 
		#you change directions
		pass
	
	rate *= speed_factor
	return rate
