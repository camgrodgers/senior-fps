extends Node
var preconditions = {
	"has_target" : false,
}

var effects = {
	"patrolling" : false,
}
export var cost = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func move_to(enemy: KinematicBody) -> Array:
	return [enemy.patrolNodes[enemy.patrolNodeIndex].translation, true]

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
