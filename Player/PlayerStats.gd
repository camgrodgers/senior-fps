extends Node

var danger_level = 0
var danger_decrease_acceleration = 0.1
var danger_decrease_velocity = 0


func _physics_process(delta):
	danger_update(delta)
#	danger_test(delta)

#Logic for rate of decreasing the danger levels
func danger_update(delta):
	
	danger_level = 0
	# NOTE: This is turning into reference spaghetti, control of this stuff should
	#		probably be centralized
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.player_danger -= (danger_decrease_velocity / enemies.size())
		danger_level += e.player_danger
	
	danger_level = clamp(danger_level, 0, 100)
	
	danger_decrease_velocity += (danger_decrease_acceleration * delta)
	
	if danger_level == 0:
		danger_decrease_velocity = 0

#Interaction with enemies
func danger_increase(rate, distance):
	danger_decrease_velocity = 0
	
	# Consider adding a factor for whether they're crouching... might be unneeded though
	# Add stuff for player speed later
	
#	danger_level = clamp(danger_level + rate , 0, 100)

#func danger_decrease(amount):
#	danger_level = clamp(danger_level - amount, 0, 100)

#For debugging
#func danger_test(delta):
#	var test_danger = 0
#	if Input.is_action_pressed("danger_test"):
#		test_danger = 30
#		danger_increase(test_danger * delta, 0)
#
#	if Input.is_action_pressed("remove_danger"):
#		danger_decrease(5)
