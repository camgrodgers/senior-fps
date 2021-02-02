extends KinematicBody

var ENEMY_SPEED = 4.0

var nav: Navigation = null
var target = null
var navNodes: Array = []
var patrolNodes: Array = []
var coverNodes: Array = []
var path: Array = []
var progress: float = 0
var last_valid_path_of_target: Array = []
var last_valid_coordinate

var currentNode = null
var patrolNodeIndex = 1

var TestNodeIndex = 0

enum {
	FIND,
	HOLD,
	PATROL,
	FIND_COVER,
	TAKE_COVER,
	SHOOT
}

var state = PATROL

func update_path():
	if path.empty() || path[path.size() - 1].distance_to(target.translation) > 10:
		prep(target.translation)
	if path.empty():
		path.push_front(last_valid_coordinate)
	if path[0] != null:
		last_valid_coordinate = path[0]

func prep(location):
	path = nav.get_simple_path(translation, location, true)
	path = Array(path)
	for p in path:
		p.y = translation.y
	last_valid_path_of_target = path

func prep_node(node):
	if currentNode != null:
		currentNode.occupied = false
	path = nav.get_simple_path(translation, node.translation, true)
	path = Array(path)
	for p in path:
		p.y = translation.y
	currentNode = node
	currentNode.occupied = true

func get_shortest_node():
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = 0
	var currentNodePathIndex = 0
	for n in coverNodes:
		if n.occupied:
			continue
		var path_to_node = nav.get_simple_path(translation, n.translation, true)
		var total_distance = get_path_distance(path_to_node)
		if total_distance < shortestNodePathDistance:
			shortestNodePathIndex = currentNodePathIndex
			shortestNodePathDistance = total_distance
		currentNodePathIndex += 1
	prep_node(coverNodes[shortestNodePathIndex])

func check_vision():
	var collisions = $VisionCone.get_overlapping_bodies()
	for collider in collisions:
		if collider.has_method("danger_increase"):
			target = collider
			return true

func aim_at_player(delta):
	var space_state = get_world().direct_space_state
	for h in target.hitboxes():
		var body_ray = space_state.intersect_ray($Hitbox.global_transform.origin, h.global_transform.origin, [self])
		if body_ray.empty():
			print("empty ray")
			# Something very messed up must have happened
			# return an error or something here
			return
		
		var collider = body_ray.collider
		print(collider)
		if collider != target:
			return
		else:
			break
	
	look_at(target.translation, Vector3(0,1,0))
	rotation_degrees.x = 0
	endanger_player(delta)

func endanger_player(delta):	
	var distance = target.translation.distance_to(translation)
	
	var rate = 0
	if distance > 50:
		rate = 0
	elif distance > 30:
		rate = 5
	elif distance > 20:
		rate = 10
	elif distance > 10:
		rate = 15
	elif distance > 5:
		rate = 20
	else:
		rate = 30
	
	rate *= delta
	target.danger_increase(rate, distance)

func _process(delta):
	var moving = ENEMY_SPEED * delta
#	path = nav.get_simple_path(translation, target.translation, true)
#	path = Array(path)
#	print(path)
#	for p in path:
#		var sphere: CSGSphere = CSGSphere.new()
#		sphere.set_name("asdf")
#		get_parent().add_child(sphere)
#
#		sphere.translation = p
#	progress += delta * .5
#	print(progress)
#	self.translation = path[round(progress)]
	
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
			if currentNode.visible_to_player:
				state = FIND_COVER
				clear_node_data()
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
			translation = translation.linear_interpolate(to, moving / distance)
			
		SHOOT:
			if currentNode.visible_to_player:
				state = FIND_COVER
				clear_node_data()
				return
			###TO DO: ADD POPPING OUT OF COVER###
			aim_at_player(delta)
func take_damage():
	self.queue_free()
	
func get_absolute_distance(point):
	return translation.distance_to(point)

func get_path_distance(path_array):
	var total_distance = translation.distance_to(path_array[0])
	for i in range(path_array.size() - 1):
		total_distance += path_array[i].distance_to(path_array[i + 1])
	return total_distance

func clear_node_data():
	path.clear()
	if currentNode != null:
		currentNode.occupied = false
		currentNode = null
