extends Node

var danger_level: float = 0
var danger_decrease_acceleration: float = 0.1
# NOTE: This could be changed to a per-enemy value
var danger_decrease_velocity: float = 0
var last_known_position = null
var known_cover_position: bool = false
var hidden_from_enemies: bool = true

func _physics_process(delta):
	danger_update(delta)

# Handles enemy and player data
func danger_update(delta):
	var new_danger_level: float = 0
	var new_hidden_from_enemies: bool = true
	
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		last_known_position = null
		hidden_from_enemies == true
		new_hidden_from_enemies == true
		known_cover_position == false
	for e in enemies:
		if e.can_see_player:
			new_hidden_from_enemies = false
			danger_decrease_velocity = 0
			break
	
	if new_hidden_from_enemies == false and hidden_from_enemies == true:
		last_known_position = null
	if new_hidden_from_enemies == true and hidden_from_enemies == false:
		last_known_position = get_parent().translation
	
	hidden_from_enemies = new_hidden_from_enemies

	if last_known_position != null and last_known_position.distance_to(get_parent().translation) < 6:
		danger_decrease_velocity = 0.05
		known_cover_position = true
	else:
		known_cover_position = false
	
	for e in enemies:
		var rate = rate_of_danger_increase(e)
		e.player_danger = clamp(e.player_danger + (rate * delta), 0, 100)
#		print("rate: {%f} danger: {%f}" % [rate, e.player_danger])
		if hidden_from_enemies:
			e.player_danger -= (danger_decrease_velocity / enemies.size())
		new_danger_level += e.player_danger
	
	new_danger_level = clamp(new_danger_level, 0, 100)
	danger_decrease_velocity += (danger_decrease_acceleration * delta)
	
	if new_danger_level == 0:
		danger_decrease_velocity = 0
	
	danger_level = new_danger_level

func rate_of_danger_increase(enemy) -> float:
	var player_distance: float = enemy.player_distance
	var player_speed: float = get_parent().vel.abs().length()
	
	if not enemy.can_see_player:
		return 0.0
	
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
