extends Node
var preconditions = {
	"has_target" : false,
}

var effects = {
	"patrolling" : false,
}
var cost = 1

var path_updated = false


func move_to(enemy: KinematicBody, delta: float):
	
	if not path_updated:
		enemy.update_path(enemy.patrolNodes[enemy.patrolNodeIndex].global_transform.origin)
		path_updated = true
	enemy.move_along_path(delta, true)
	enemy.check_vision()
	if enemy.world_state["has_target"]:
		enemy.world_state["patrolling"] = false
		enemy.alert_comrades()
		path_updated = false
		enemy.clear_node_data()
		enemy.replan_actions()
	if enemy.path.empty() :
		path_updated = false
		enemy.ready_for_action()
		return true
	
	return false

func take_action(enemy: KinematicBody, delta: float):
	
	enemy.check_vision()
	if enemy.world_state["has_target"]:
		enemy.world_state["patrolling"] = false
		enemy.alert_comrades()
		enemy.clear_node_data()
		enemy.replan_actions()
	
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
	enemy.go_to_next_action()
