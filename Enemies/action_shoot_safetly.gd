extends Node

var preconditions = {
	"has_target" : true,
	"in_cover": true,
	"in_range": true,
	"in_danger": true
}

var effects = {
	"in_danger" : false,
	"has_target" : false
}

var cost = 1
var path_updated = false
var safety_cover_timer = 0
var crouched = false
var crouch_timer = 0.0
var crouch_distance = 1.0

func move_to(enemy: Enemy, delta: float) -> bool:
	
	safety_cover_timer += delta
	if not (enemy.currentNode in enemy.coverNodes):
		enemy.clear_node_data()
		enemy.replan_actions()
		if crouched:
			enemy.translation.y += crouch_distance
			crouched = false
			crouch_timer = 0.0
		safety_cover_timer = 0
		path_updated = false
		return true
	
	enemy.check_vision()
	if enemy.world_state["can_see_player"] == true && not path_updated && enemy.currentNode in enemy.coverNodes:
		enemy.translation.y -= crouch_distance
		crouched = true
		enemy.ready_for_action()
		return true
	if not path_updated and safety_cover_timer > 3.5:
		enemy.update_path(enemy.player.translation)
		path_updated = true
		safety_cover_timer = 0
	if path_updated:
		enemy.move_along_path(delta)
		enemy.aim_at_player(delta)
		enemy.check_vision()
	
	if enemy.world_state["can_see_player"] == true:
		enemy.ready_for_action()
		path_updated = false
		return true
	return false
	
func take_action(enemy: KinematicBody, delta: float) -> bool:
	if not enemy.check_range():
		enemy.replan_actions()
		enemy.clear_node_data()
		if crouched:
			enemy.translation.y += crouch_distance
			crouched = false
			return true
	if crouched:
		enemy._shoot_timer += delta
		crouch_timer += delta
		if not (enemy.currentNode in enemy.coverNodes):
			enemy.shoot_around_player(delta)
			enemy.go_to_next_action()
			enemy.translation.y += crouch_distance
			crouch_timer = 0.0
			crouched = false
			return true
		if crouch_timer < 5.0 or enemy._shoot_timer < enemy._shoot_interval:
			return false
		crouch_timer = 0.0
		enemy.translation.y += crouch_distance
		crouched = false
		if enemy.world_state["can_see_player"]:
			enemy.shoot_around_player(delta)
			enemy.go_to_next_action()
			return true
			
	enemy.cover_timer += delta
	enemy.aim_at_player(delta)
	if enemy.world_state["can_see_player"]:
		enemy.shoot_around_player(delta)
	if enemy.cover_timer > 1.5:
		enemy.cover_timer = 0
		if enemy.translation.distance_to(enemy.currentNode.translation) > 1:
			enemy.world_state["in_cover"] = false
			enemy.clear_node_data()
		enemy.go_to_next_action()
		return true
	return false
