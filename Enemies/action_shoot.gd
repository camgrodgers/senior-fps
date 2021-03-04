extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var preconditions = {
	"has_target" : true,
	"in_cover": true	
}

var effects = {
	"has_target" : false
}

var cost = 1


func move_to(enemy: KinematicBody, delta: float) -> bool:
	enemy.update_path(enemy.player.translation)
	enemy.move_along_path(delta, true)
	if enemy.world_state["can_see_player"] == true:
		enemy.ready_for_action()
		return true
	return false
	
func take_action(enemy: KinematicBody, delta: float) -> bool:
	
	enemy.cover_timer += delta
	enemy.aim_at_player(delta)
	if enemy.cover_timer > 3:
		enemy.cover_timer = 0
		enemy.get_node("Enemy_audio_player").play_sound(enemy.get_node("Enemy_audio_player").enemy_shot)
		enemy.world_state["in_cover"] = false
		enemy.go_to_next_action()
		return true
	return false
	
