extends Node



var preconditions = {
	"has_target" : true,
	"in_cover": true,
	"in_range": true,
}

var effects = {
	"has_target" : false
}

var cost = 2
var path_updated = false
var peek_timer = 0.0
var crouch_timer = 0.0
var crouch_distance = 1.0

func move_to(enemy: Enemy, delta: float) -> bool:
	
	enemy.check_vision()
	if enemy.world_state["can_see_player"] == true && not path_updated && not enemy.currentNode.visible_to_player:
		enemy.translation.y -= crouch_distance
		enemy.world_state["crouched"] = true
		enemy.set_damage(0.0)
		enemy.ready_for_action()
		return true
	
	if not path_updated:
		enemy.update_path(enemy.player.translation)
		path_updated = true
	enemy.move_along_path(delta)
	enemy.aim_at_player(delta)
	if enemy.check_vision():
		peek_timer += delta
	
	if enemy.world_state["can_see_player"] == true and peek_timer > 0.5:
		enemy.ready_for_action()
		path_updated = false
		peek_timer = 0.0
		return true
	return false
	
func take_action(enemy: KinematicBody, delta: float) -> bool:
	if not enemy.check_range():
		enemy.replan_actions()
		enemy.clear_node_data()
		if enemy.world_state["crouched"]:
			enemy.translation.y += crouch_distance
			enemy.world_state["crouched"] = false
			enemy.reset_damage()
			return true
	
	if enemy.world_state["crouched"]:
		crouch_timer += delta
		if enemy.currentNode.visible_to_player:
			enemy.shoot_around_player(delta)
			enemy.go_to_next_action()
			enemy.translation.y += crouch_distance
			crouch_timer = 0.0
			enemy.world_state["crouched"] = false
			enemy.reset_damage()
			return true
		if crouch_timer < 3.0:
			return false
		crouch_timer = 0.0
		enemy.translation.y += crouch_distance
		enemy.world_state["crouched"] = false
		enemy.reset_damage()
	
	enemy.check_vision()
	enemy.aim_at_player(delta)
	if enemy.world_state["can_see_player"]:
		enemy.shoot_around_player(delta)
	
	enemy.cover_timer += delta
	if enemy.cover_timer > 1.5:
		enemy.cover_timer = 0
		if enemy.translation.distance_to(enemy.currentNode.translation) > 1:
			enemy.world_state["in_cover"] = false
			enemy.clear_node_data()
		enemy.go_to_next_action()
		return true
	return false
	
