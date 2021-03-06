extends Node

var danger_level: float = 0
var danger_level_orange: float = 0
var danger_decrease_acceleration: float = 6
# NOTE: This could be changed to a per-enemy value
var danger_decrease_velocity: float = 0
var known_cover_position: bool = false
var hidden_from_enemies: bool = true

func _process(delta):
	danger_update(delta)

# Handles enemy and player data
func danger_update(delta):
	#TODO: all of this stuff needs to be replaced with encapsulated enemy logic?
	var player_position = get_parent().translation
	danger_level = 0
	danger_level_orange = 0
	known_cover_position = false
	hidden_from_enemies = true

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		hidden_from_enemies = true
		known_cover_position = false
	for e in enemies:
		if e.world_state["can_see_player"]:
			hidden_from_enemies = false
			danger_decrease_velocity = 0
		if e.last_player_position.distance_to(player_position) < 6:
			known_cover_position = true
			danger_decrease_velocity = 0

	for e in enemies:
		var rate = rate_of_danger_increase(e)
		e.player_danger = clamp(e.player_danger + (rate * delta), 0, 100)
		if ((not e.world_state["can_see_player"])
				and e.last_player_position.distance_to(player_position) < 6):
			e.player_danger -= 3 * delta
			danger_level_orange += e.player_danger
		elif hidden_from_enemies and not known_cover_position:
			e.player_danger -= (danger_decrease_velocity / enemies.size()) * delta

		danger_level += e.player_danger
	
	danger_level = clamp(danger_level, 0, 100)
	danger_level_orange = clamp(danger_level_orange, 0, 100)
	danger_decrease_velocity += (danger_decrease_acceleration * delta)
	
	if danger_level == 0:
		danger_decrease_velocity = 0

func rate_of_danger_increase(enemy) -> float:
	var player_distance: float = enemy.player_distance
	var player_speed: float = get_parent().vel.abs().length()
#	print(player_speed)
	
	if not enemy.world_state["can_see_player"]:
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
	
	var speed_factor: float = 1
	if player_speed < 4:
		speed_factor = 2
	elif player_speed > 15:
		speed_factor = 0.75
		#add a timer or something for the speed factor so it doesn't immediately go up when 
		#you change directions
		pass
	
	rate *= speed_factor
	return rate
