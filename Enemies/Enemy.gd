extends KinematicBody

var ENEMY_SPEED = 4.0

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

func update_path(goal: Vector3) -> void:
	var new_path: PoolVector3Array = nav.get_simple_path(translation, goal, true)
	new_path = Array(path)
	if new_path == null or new_path.empty():
		print("got null path")
		return
	path = new_path

func move_along_path(delta: float, lookat: bool = false) -> void:
	if path == null or path.empty():
		print("null or empty path")
		return
	
	var moving = ENEMY_SPEED * delta
	var to = path[0]
	var distance = translation.distance_to(to)
	
	if distance < moving:
		path.pop_front()
		return
		
	var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
	if lookat:
		look_at(global_transform.origin + velocity, Vector3.UP)
#	translation = translation.linear_interpolate(to, moving / distance)
	move_and_slide(velocity, Vector3.UP)

func get_shortest_node():
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = null
	var currentNodePathIndex = 0
	for n in coverNodes:
		if n.occupied:
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
		prep_node(currentNode)
		return
	prep_node(coverNodes[shortestNodePathIndex])

func prep_node(node):
	clear_node_data()
	update_path(node.translation)
	currentNode = node
	currentNode.occupied = true
	currentNode.occupied_by = self

func check_vision() -> bool:
	var collisions = $VisionCone.get_overlapping_bodies()
	for collider in collisions:
		if collider.is_in_group("player"):
			can_see_player = cast_to_player_hitboxes()
#			target = collider
			return can_see_player
	
	return false

# If it returns true, a raycast can hit the player's hitboxes
func cast_to_player_hitboxes() -> bool:
	var space_state = get_world().direct_space_state
	for h in player.hitboxes():
		var body_ray = space_state.intersect_ray($Gun.global_transform.origin, h.global_transform.origin, [self])
		if body_ray.empty():
			print("empty ray")
			# TODO: why does this keep printing?
			continue
		
		var collider = body_ray.collider
#		print(collider)
		if collider == player:
			return true
			
	return false

func aim_at_player(_delta):
	can_see_player = cast_to_player_hitboxes()
	if not can_see_player: return
	player_distance = player.translation.distance_to(translation)
		# Could change this to relative velocity later?
	# TODO: find out why player velocity is >0 when standing still
#	target_speed = target.vel.abs().length()
	
	look_at(player.translation, Vector3(0,1,0))
	rotation_degrees.x = 0

func _physics_process(delta):
	
	match state:
		FIND:
			aim_at_player(delta)
			update_path()
			var to = path[0]
			var distance = translation.distance_to(to)
			var total_distance = get_absolute_distance(target.translation)
			if total_distance <= 10:
				state = HOLD
				path.clear()
			if distance < moving:
				path.pop_front()
				return
			
			translation = translation.linear_interpolate(to, moving / distance)
		HOLD:
			aim_at_player(delta)
			update_path()
			if path.empty():
				return
			var to = path[0]
			var distance = translation.distance_to(to)
			var total_distance = get_absolute_distance(target.translation)
			if total_distance > 15:
				path.clear()
				state = FIND
				
		PATROL:
			if check_vision():
				state = FIND_COVER
				clear_node_data()
			if $PatrolTimer.get_time_left() > 0:
				return
			else:
				if path.size() < 1:
					prep_node(patrolNodes[patrolNodeIndex])
					if patrolNodeIndex == patrolNodes.size() - 1:
						patrolNodeIndex = 0
					else:
						patrolNodeIndex += 1
					$PatrolTimer.start()
				var to = path[0]
				var distance = translation.distance_to(to)
				var total_distance = get_absolute_distance(target.translation)
				
				if distance < moving:
					path.pop_front()
					return
					
				var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
				look_at(global_transform.origin + velocity, Vector3.UP)
				translation = translation.linear_interpolate(to, moving / distance)
				
		FIND_COVER:
			
			get_shortest_node()
			aim_at_player(delta)
			state = TAKE_COVER
			
		TAKE_COVER:
			if currentNode.visible_to_player || currentNode.occupied_by != self:
				state = FIND_COVER
				path.clear()
				return
			
			aim_at_player(delta)
			if path.empty():
				state = SHOOT
				return
			
			var to = path[0]
			var distance = translation.distance_to(to)
			
			if distance < moving:
				path.pop_front()
				return
			var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
			move_and_slide(velocity, Vector3.UP)
			
		SHOOT:
			###TO DO: ADD POPPING OUT OF COVER###
			aim_at_player(delta)
			if currentNode == null: return
			if currentNode.visible_to_player:
				state = FIND_COVER
				path.clear()
				return

func take_damage():
	var corpse_scn: Resource = preload("res://Enemies/DeadEnemy.tscn")
	var corpse = corpse_scn.instance()
	corpse.transform = self.transform
	get_parent().add_child(corpse)
	clear_node_data()
	self.queue_free()
	
#func get_absolute_distance(point):
#	return translation.distance_to(point)

func get_path_distance(path_array):
	var total_distance = translation.distance_to(path_array[0])
	for i in range(path_array.size() - 2):
		total_distance += path_array[i].distance_to(path_array[i + 1])
	return total_distance

func clear_node_data():
	path.clear()
	if currentNode != null:
		currentNode.occupied = false
		currentNode.occupied_by = null
		currentNode = null
