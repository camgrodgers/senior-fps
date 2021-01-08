extends KinematicBody


var nav: Navigation = null
var target = null
var navNodes: Array = []
var path: Array = []
var progress: float = 0

var numNodes = 0
var nodeIndex = 0

enum {
	FIND,
	HOLD,
	PATROL
}

var state = FIND

func _ready():
	pass
	
func prep():
	path = nav.get_simple_path(translation, target.translation, true)
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

func _process(delta):
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
			if path.size() < 1:
				prep()
			var speed = 4.0
			var moving = speed * delta
			var to = path[0]
			var distance = translation.distance_to(to)
			var total_distance = 0
			for point in path:
				total_distance += translation.distance_to(point)
			if total_distance <= 15:
				state = HOLD
				path.clear()
			if distance < moving:
				path.pop_front()
				return
			
			translation = translation.linear_interpolate(to, moving / distance)
		HOLD:
			prep()
			var to = path[0]
			var distance = translation.distance_to(to)
			var total_distance = 0
			for point in path:
				total_distance += translation.distance_to(point)
			if total_distance > 25:
				state = PATROL
				path.clear()
		PATROL:
			if path.size() < 1:
				get_shortest_node()
			var speed = 4.0
			var moving = speed * delta
			var to = path[0]
			var distance = translation.distance_to(to)
			if distance < moving:
				path.pop_front()
				return
			translation = translation.linear_interpolate(to, moving / distance)
	
func take_damage():
	self.queue_free()

