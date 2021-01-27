extends KinematicBody

var ENEMY_SPEED = 4.0

var nav: Navigation = null
var target = null
var navNodes: Array = []
var patrolNodes: Array = []
var path: Array = []
var progress: float = 0
var last_valid_vector_of_target = Vector3.ZERO

var nodeIndex = 0
var patrolNodeIndex = 1

var TestNodeIndex = 0

enum {
	FIND,
	HOLD,
	PATROL
}

var state = PATROL


func prep(location):
	path = nav.get_simple_path(translation, location)
	path = Array(path)
	if path.empty():
		path = nav.get_simple_path(translation, last_valid_vector_of_target)
		path = Array(path)
	for p in path:
		p.y = translation.y
func prep_node(node):
	path = nav.get_simple_path(translation, node.translation, true)
	path = Array(path)
	for p in path:
		p.y = translation.y

func get_shortest_node():
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = 0
	var currentNodePathIndex = 0
	for n in navNodes:
		path = nav.get_simple_path(translation, n.translation, true)
		var total_distance = 0
		for point in path:
				total_distance += translation.distance_to(point)
		if total_distance < shortestNodePathDistance:
			shortestNodePathIndex = currentNodePathIndex
			shortestNodePathDistance = total_distance
		currentNodePathIndex += 1
	return prep_node(navNodes[shortestNodePathIndex])

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
	
	var velocity = translation.direction_to(target.translation).normalized() * ENEMY_SPEED
	look_at(global_transform.origin + velocity, Vector3.UP)
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
			if path.empty() || path[path.size() - 1].distance_to(target.translation) > 10:
				prep(target.translation)
			if path.empty():
				prep(last_valid_vector_of_target)
				return
			var to = path[0]
			last_valid_vector_of_target = target.translation
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
			if path.size() < 1 || path[path.size() - 1].distance_to(target.translation) > 10:
				prep(target.translation)
			if path.empty():
				prep(last_valid_vector_of_target)
				return
			var to = path[0]
			last_valid_vector_of_target = target.translation
			var distance = translation.distance_to(to)
			var total_distance = get_absolute_distance(target.translation)
			if total_distance > 15:
				path.clear()
				state = FIND
				
		PATROL:
			if check_vision():
				state = FIND
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
				
#				if check_vision():
#					state = FIND
				
				if distance < moving:
					path.pop_front()
					return
					
				var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
				look_at(global_transform.origin + velocity, Vector3.UP)
				translation = translation.linear_interpolate(to, moving / distance)
				
			
	
func take_damage():
	self.queue_free()
	
func get_absolute_distance(point):
	return translation.distance_to(point)

func get_path_distance():
	var total_distance = path[0]
	for i in range(path.size() - 1):
		total_distance += path[i].distance_to(path[i + 1])
	return total_distance
