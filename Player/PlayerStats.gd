extends Node

var danger_level = 0
var danger_decrease_acceleration = 0.1
var danger_decrease_velocity = 0


func _physics_process(delta):
	danger_update(delta)
	danger_test(delta)

#Logic for rate of decreasing the danger levels
func danger_update(delta):
	danger_decrease_velocity += (danger_decrease_acceleration * delta)
	
	danger_level = clamp(danger_level - danger_decrease_velocity, 0, 100)
	
	if danger_level == 0:
		danger_decrease_velocity = 0

#Interaction with enemies
func danger_increase(rate):
	danger_decrease_velocity = 0
	
	# Consider adding a factor for whether they're crouching... might be unneeded though
	# Add stuff for player speed later
	
	danger_level = clamp(danger_level + rate , 0, 100)

func danger_decrease(amount):
	danger_level = clamp(danger_level - amount, 0, 100)

#For debugging
func danger_test(delta):
	var test_danger = 0
	if Input.is_action_pressed("danger_test"):
		test_danger = 30
		danger_increase(test_danger * delta)
	
	if Input.is_action_pressed("remove_danger"):
		danger_decrease(5)
