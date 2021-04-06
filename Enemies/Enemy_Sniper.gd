extends Enemy

func _init():
	ENEMY_RANGE = 185
	_shoot_interval = 2.0
	MINIMUM_RANGE = 50
	WOUNDED_RANGE = 80
	DAMAGE_MULTIPLIER = 0.0
	
func _ready():
	$Enemy_audio_player.enemy_shot = preload("res://Sounds/Game_Over_shot.wav")
	$Enemy_audio_player.destruction_alert = preload("res://Sounds/Laser_Sight.wav")

func rate_of_danger_increase() -> float:
	var player_speed: float = player.vel.length()
	
	if not world_state["can_see_player"] || current_damage_mult == 0.0:
		return 0.0
	
	var rate: float = 0
	if player_distance > 300:
		rate = 5
	elif player_distance > 200:
		rate = 10
	elif player_distance > 150:
		rate = 25
	elif player_distance > 100:
		rate = 20
	elif player_distance > 25:
		rate = 15
	elif player_distance > 10:
		rate = 1
	else:
		rate = 1
	
	rate = rate * current_damage_mult
	
	var speed_factor: float = 1
	if player_speed < 2:
		speed_factor = 2
	elif player_speed > 15:
		speed_factor = 0.5
		#TODO: add a timer or something for the speed factor so it doesn't immediately go up when 
		#you change directions
		pass
	
	rate *= speed_factor
	return rate

func set_aim():
	current_damage_mult = 1
	if not $Enemy_audio_player.playing():
		$Enemy_audio_player.play_sound($Enemy_audio_player.destruction_alert)
func unset_aim():
	current_damage_mult = 0
	if $Enemy_audio_player.playing():
		$Enemy_audio_player.stop()

func reset_damage():
	current_damage_mult = 0
	if $Enemy_audio_player.playing():
		$Enemy_audio_player.stop()

func get_shortest_node():
	var coverNodes = get_tree().get_nodes_in_group(
			"navnodes_not_seen_by_player"
		)
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = null
	var currentNodePathIndex = 0
	var minimumRangeNodePathIndex = null
	var minimumRangeNodePathDistance = INF
	var sniperNodeIndex = null
	var sniperNodeDistance = INF
	for n in coverNodes:
		if n.occupied == true:
			currentNodePathIndex += 1
			continue
		var path_to_node = nav.get_simple_path(global_transform.origin,
						n.global_transform.origin,
						true)
		var total_distance = get_path_distance(path_to_node)
		if total_distance < shortestNodePathDistance:
			shortestNodePathIndex = currentNodePathIndex
			shortestNodePathDistance = total_distance
		if total_distance < minimumRangeNodePathDistance && n.translation.distance_to(player.translation) > MINIMUM_RANGE:
			minimumRangeNodePathIndex = currentNodePathIndex
			minimumRangeNodePathDistance = total_distance
		if n.name == "NavNodeSniper" && total_distance < sniperNodeDistance && n.translation.distance_to(player.translation) > MINIMUM_RANGE:
			sniperNodeDistance = total_distance
			sniperNodeIndex = currentNodePathIndex
		currentNodePathIndex += 1
	if shortestNodePathIndex == null:
		print("no free nodes")
		if currentNode != null: return currentNode
		for node in get_tree().get_nodes_in_group("navnodes_seen_by_player"):
			if not node.occupied:
				return node
	if sniperNodeIndex == null:
		if minimumRangeNodePathIndex == null:
			return coverNodes[shortestNodePathIndex]
		return coverNodes[minimumRangeNodePathIndex]
	return coverNodes[sniperNodeIndex]
