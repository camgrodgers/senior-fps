extends KinematicBody
class_name Enemy

var ENEMY_SPEED: int = 6

var nav: Navigation = null
var target = null
var player = null
var patrolNodes: Array = []
var coverNodes: Array = []
var path: Array = []
var last_valid_path_of_target: Array = []
var last_valid_coordinate

var patrolNodeIndex = 1
var currentNode = null

var TestNodeIndex = 0

# Relations to player
var player_distance: float = 0.0
var can_see_player: bool = false
var player_danger: float = 0.0

enum {
	FIND,
	HOLD,
	PATROL,
	FIND_COVER,
	TAKE_COVER,
	SHOOT
}

var state = PATROL

func _ready():
	rng.randomize()
	cover_timer_limit = rng.randf_range(1, 10)

# Updates the path variable to lead to a new destination
func update_path(goal: Vector3) -> void:
	var new_path_pool: PoolVector3Array = nav.get_simple_path(translation, nav.get_closest_point(goal), true)
	var new_path: Array = Array(new_path_pool)
	if new_path == null or new_path.empty():
		print("got null path")
		return
	path = new_path

# Moves the enemy along the path held in 'path'
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
	
	var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
	if lookat:
		look_at(global_transform.origin + velocity, Vector3.UP)
#	translation = translation.linear_interpolate(to, moving / distance)
	move_and_slide(velocity, Vector3.UP)

# Find the nearest node to take cover at
func get_shortest_node():
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = null
	var currentNodePathIndex = 0
	for n in coverNodes:
		if n.occupied == true:
			currentNodePathIndex += 1
			continue
		var path_to_node = nav.get_simple_path(translation, n.translation, true)
		var total_distance = get_path_distance(path_to_node)
		if total_distance < shortestNodePathDistance:
			shortestNodePathIndex = currentNodePathIndex
			shortestNodePathDistance = total_distance
		currentNodePathIndex += 1
	if shortestNodePathIndex == null:
		print("no free nodes")
		return currentNode
	return coverNodes[shortestNodePathIndex]

func prep_node(node):
	if currentNode != node:
		clear_node_data()
	update_path(node.translation)
	currentNode = node
	currentNode.occupied = true
	currentNode.occupied_by = self

# Check if player is visible inside the enemy's vision cone
func check_vision() -> bool:
	var collisions = $VisionCone.get_overlapping_areas()
	if collisions.empty():
		can_see_player = false
		return false
	
	can_see_player = cast_to_player_hitboxes()
#			target = collider
	return can_see_player

# If it returns true, a raycast can hit the player's hitboxes
func cast_to_player_hitboxes() -> bool:
	var space_state = get_world().direct_space_state
	for h in player.hitboxes():
		var body_ray = space_state.intersect_ray(
			$Gun.global_transform.origin,
			h.global_transform.origin,
			[self], # exclude
			0b0011, # collides with 0...0, player, world
			true, # collide with bodies  
			true) # collide with areas
		if body_ray.empty():
			print("empty ray")
			# TODO: why does this keep printing?
			continue
		
		var collider = body_ray.collider
#		print(collider)
		if collider == player:
			return true
			
	return false

# If can see player, turn to look at the player
func aim_at_player(_delta):
	can_see_player = cast_to_player_hitboxes()
	if not can_see_player: return
	player_distance = player.translation.distance_to(translation)
		# Could change this to relative velocity later?
	# TODO: find out why player velocity is >0 when standing still
#	target_speed = target.vel.abs().length()
	
	look_at(player.translation, Vector3(0,1,0))
	rotation_degrees.x = 0

var rng = RandomNumberGenerator.new()
var cover_timer = 0
var cover_timer_limit = 3

func _process(delta):
	match state:
		FIND:
			if can_see_player:
				cover_timer += delta
				var distance = translation.distance_to(player.translation)
				if distance <= 10:
					state = FIND_COVER
					cover_timer = 0
					return
			if cover_timer > 3:
				cover_timer = 0
				state = FIND_COVER
				return
			aim_at_player(delta)
			update_path(player.translation)
			move_along_path(delta)

#				path.clear()
		HOLD:
			aim_at_player(delta)
			var distance = translation.distance_to(player.translation)
			if distance > 10:
				state = FIND
		PATROL:
			if check_vision():
				alert_comrades()
				state = FIND_COVER
				clear_node_data()
				return
			if $PatrolTimer.get_time_left() > 0:
				return
			else:
				prep_node(patrolNodes[patrolNodeIndex])
				move_along_path(delta, true)
				if path.size() < 1:
					prep_node(patrolNodes[patrolNodeIndex])
					if patrolNodeIndex == patrolNodes.size() - 1:
						patrolNodeIndex = 0
					else:
						patrolNodeIndex += 1
					$PatrolTimer.start()
		FIND_COVER:
			prep_node(get_shortest_node())
			
			state = TAKE_COVER
		TAKE_COVER:
			if currentNode.visible_to_player:
				state = FIND_COVER
				return
			move_along_path(delta)
			aim_at_player(delta)
			if path.empty():
				state = SHOOT
				return
		SHOOT:
			###TO DO: ADD POPPING OUT OF COVER###
			aim_at_player(delta)
			cover_timer += delta
			if cover_timer > cover_timer_limit:
				state = FIND
				cover_timer = 0
				return
			if currentNode.visible_to_player:
				state = FIND_COVER
				return


# Length of path to a point
func get_path_distance_to(goal: Vector3) -> float:
	# TODO: What if this is null?
	var temp_path_pool: PoolVector3Array = nav.get_simple_path(translation, goal, true)
	var temp_path: Array = Array(temp_path_pool)
	return get_path_distance(temp_path)

# Length of a path
func get_path_distance(path_array: Array) -> float:
	var total_distance: float = translation.distance_to(path_array[0])
	for i in range(path_array.size() - 2):
		total_distance += path_array[i].distance_to(path_array[i + 1])
	return total_distance

func clear_node_data() -> void:
	path.clear()
	if currentNode != null:
		currentNode.occupied = false
		currentNode.occupied_by = null

# Respond to player attacks
var HP: int = 2

func take_damage() -> void:
	alert_comrades()
	HP -= 1
	if HP > 0:
		$CSGCombiner/CSGCylinder.visible = false
		$CSGCombiner/CSGCylinder2.visible = true
		return
	var corpse_scn: Resource = preload("res://Enemies/DeadEnemy.tscn")
	var corpse = corpse_scn.instance()
	corpse.transform = self.transform
	# TODO: replace this with something that lets the level manage corpses
	get_parent().get_parent().add_child(corpse)
	clear_node_data()
	self.queue_free()

func alert_comrades() -> void:
	# TODO: Replace this with something that's restricted to a certain area, and/or a signal?
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.state == PATROL:
			e.state = TAKE_COVER
