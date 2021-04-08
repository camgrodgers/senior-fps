extends Node

var preconditions = {
	"in_cover": true,
}

var effects = {
	"in_cover" : false
}

var cost = 1
var path_updated = false


func move_to(enemy: KinematicBody, delta: float) -> bool:
	
	enemy.world_state["in_cover"] = false
	enemy.ready_for_action()
	return true

func take_action(enemy: KinematicBody, delta: float):
	enemy.clear_node_data()
	enemy.go_to_next_action()
