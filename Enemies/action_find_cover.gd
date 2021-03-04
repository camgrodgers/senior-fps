extends Node

var preconditions = {
	"in_cover": false,
}

var effects = {
	"in_cover" : true
}

var cost = 1
var path_updated = false


func move_to(enemy: KinematicBody, delta: float) -> bool:
	
	if not path_updated or enemy.currentNode.visible_to_player:
		enemy.prep_node(enemy.get_shortest_node())
	enemy.check_vision()
	if enemy.world_state["can_see_player"] == true:
		enemy.aim_at_player(delta)
		if not enemy.get_node("Enemy_audio_player").playing():
			enemy.get_node("Enemy_audio_player").play_sound(enemy.get_node("Enemy_audio_player").enemy_shot)
	enemy.move_along_path(delta)
	if enemy.path.empty():
		enemy.ready_for_action()
		path_updated = false
		return true
	return false

func take_action(enemy: KinematicBody, delta: float):
	enemy.world_state["in_cover"] = true
	enemy.go_to_next_action()
