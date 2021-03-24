extends Node

var preconditions = {
	"in_range": true,
}

var effects = {
	"has_target" : false
}

var cost = 1
var path_updated = false
var last_player_position = null
var self_destruct_timer = 0.0
var explosion_timer = 0.0
var exploded = false

func move_to(enemy: KinematicBody, delta: float) -> bool:
	
	self_destruct_timer += delta
	enemy.beep()
	if self_destruct_timer > 2.0:
		enemy.ready_for_action()
		enemy.set_damage(1.0)
		return true
	return false


func take_action(enemy: KinematicBody, delta: float):
	enemy.explode()
	explosion_timer += delta
	if explosion_timer > 0.5:
		enemy.take_damage(0.5)
	return false
