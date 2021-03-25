extends Node

var preconditions = {
	"in_cover": true,
	"has_target": true,
	"drone_ready":true
}

var effects = {
	"has_target" : false
}

var cost = 1
var drone = null

func move_to(enemy: KinematicBody, delta: float) -> bool:
	if not enemy.world_state["drone_ready"]:
		enemy.replan_actions()
		return false
	get_tree().call_group("enemies", "drone_in_use")
	enemy.nav.spawn_drone(enemy.translation, self)
	enemy.set_damage(0.0)
	enemy.ready_for_action()
	return true

func take_action(enemy: KinematicBody, delta: float):
	if (drone.get_ref()):
		return false
	enemy.reset_damage()
	enemy.go_to_next_action()
