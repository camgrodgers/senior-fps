extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var preconditions = {
	"in_cover": false,
}

var effects = {
	"in_cover" : true
}


var cost = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move_to(enemy: KinematicBody) -> Array:
	return [get_shortest_node(enemy), false]

func take_action(enemy: KinematicBody) -> bool:
	
	if enemy.get_node("PatrolTimer").is_paused():
		enemy.get_node("PatrolTimer").set_paused(false)
		return false
	if enemy.get_node("PatrolTimer").get_time_left() > 0:
		return false
	else:
		if enemy.patrolNodeIndex == enemy.patrolNodes.size() - 1:
			enemy.patrolNodeIndex = 0
		else:
			enemy.patrolNodeIndex += 1
		enemy.get_node("PatrolTimer").start()
		enemy.get_node("PatrolTimer").set_paused(true)
	return true

func get_shortest_node(enemy: KinematicBody):
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = null
	var currentNodePathIndex = 0
	for n in enemy.coverNodes:
		if n.occupied == true:
			currentNodePathIndex += 1
			continue
		var path_to_node = enemy.nav.get_simple_path(enemy.translation, n.translation, true)
		var total_distance = get_path_distance(enemy, path_to_node)
		if total_distance < shortestNodePathDistance:
			shortestNodePathIndex = currentNodePathIndex
			shortestNodePathDistance = total_distance
		currentNodePathIndex += 1
	if shortestNodePathIndex == null:
		print("no free nodes")
		return enemy.currentNode
	return enemy.coverNodes[shortestNodePathIndex]
	
# Length of path to a point
func get_path_distance_to(enemy: KinematicBody, goal: Vector3) -> float:
	# TODO: What if this is null?
	var temp_path_pool: PoolVector3Array = enemy.nav.get_simple_path(enemy.translation, goal, true)
	var temp_path: Array = Array(temp_path_pool)
	return get_path_distance(enemy, temp_path)

# Length of a path
func get_path_distance(enemy: KinematicBody, path_array: Array) -> float:
	var total_distance: float = enemy.translation.distance_to(path_array[0])
	for i in range(path_array.size() - 2):
		total_distance += path_array[i].distance_to(path_array[i + 1])
	return total_distance
