extends Node

var preconditions = {
	"in_cover": false,
}

var effects = {
	"in_cover" : true
}


var cost = 1

func move_to(enemy: KinematicBody) -> Array:
	return [enemy.get_shortest_node(), false]

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
