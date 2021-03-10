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
	
	if enemy.coverNodes.empty():
		enemy.ready_for_action()
		path_updated = false
		return true
	if not path_updated:
		enemy.prep_node(enemy.get_shortest_node())
		path_updated = true
	enemy.move_along_path(delta)
	enemy.check_vision()
	enemy.aim_at_player(delta)
	enemy.shoot_around_player(delta)
	if enemy.world_state["can_see_player"] == true:
		if not enemy.get_node("Enemy_audio_player").playing():
			enemy.get_node("Enemy_audio_player").play_sound(enemy.get_node("Enemy_audio_player").enemy_shot)
	
	if enemy.path.empty():
		enemy.ready_for_action()
		path_updated = false
		return true
	return false

func take_action(enemy: KinematicBody, delta: float):
	enemy.world_state["in_cover"] = true
	enemy.go_to_next_action()
