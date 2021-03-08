extends Node


class PlannerNode:
	var state: Dictionary
	var parent: PlannerNode
	var action: Node
	var given_cost: int
	var heuristic_cost: int
	var final_cost: int
	
	func _init(state, parent, given_cost, heuristic_cost, action):
		self.state = state
		self.parent = parent
		self.given_cost = given_cost
		self.heuristic_cost = heuristic_cost
		self.final_cost = given_cost + heuristic_cost
		self.action = action

var visited: Dictionary = {}
var current_goal : Node = null

#func _ready():
#	pass
	##Example use for debugging
#	var state = {"has_target" : true, "in_cover": false, "can_see_player": true}
#	var desired = {"has_target" : false}
#	print("Current State: ")
#	print(state)
#	print("Desired State: ")
#	print(desired)
#	generate_graph(state, desired)
#	plan_actions(state, desired)
#
#	##Go through solution for debugging purposes
#	var traceback:Graph_Node = goal
#	var solution: Array = []
#	while(traceback != null and visited[traceback].edge != null):
#		solution.push_front(visited[traceback].edge.action.get_name())
#		traceback = visited[traceback].parent
#	for e in solution:
#		print(e + " -> ")
#	print("goal reached!")
#	for a in get_children():
#		actions.add_child(a)

func get_goal_node(current_state: Dictionary) -> Node:
	var priority_goal: Node = null
	for goal in $Goals.get_children():
		if priority_goal == null:
			if not compare_states(current_state, goal.desired_state):
				priority_goal = goal
				continue
		elif not compare_states(current_state, priority_goal.desired_state) and priority_goal.priority > goal.priority:
			priority_goal = goal
	return priority_goal
	

func check_current_goal(current_state: Dictionary) -> bool:
	if current_goal == null or compare_states(current_state, current_goal.desired_state):
		return true
	var priority_goal: Node = null
	for goal in $Goals.get_children():
		if priority_goal == null:
			if not compare_states(current_state, goal.desired_state):
				priority_goal = goal
				continue
		elif not compare_states(current_state, priority_goal.desired_state) and priority_goal.priority > goal.priority:
			priority_goal = goal
	if current_goal == priority_goal:
		return true
	return false

func estimate_cost(current_state: Dictionary, desired_state: Dictionary):
	var hcost: int = 0
	for key in desired_state.keys():
		if current_state.has(key):
			if desired_state[key] != current_state[key]:
				hcost += 1
		else:
			hcost += 1
	return hcost


##Use A* to go through available states
##Get a list of actions to follow


func plan_actions(current_state: Dictionary):
	current_goal = get_goal_node(current_state)
	var desired_state: Dictionary = current_goal.desired_state
	$PriorityQueue._init()
	$PriorityQueue.insert(PlannerNode.new(current_state, null, 0, estimate_cost(current_state, desired_state), null))
	visited = {current_state.hash(): $PriorityQueue.peek()}
	
	while !$PriorityQueue.empty():
		var current_node = $PriorityQueue.delMin()
		
		if compare_states(current_node.state, desired_state):
			###solved!!!
			return get_solution(current_node);
		
		for action in $Actions.get_children():
			if preconditions_met(current_node.state, action):
				var successor = apply_action_effects(current_node.state, action)
				var newCost = current_node.given_cost + action.cost
				if not visited.has(successor.hash()):
					visited[successor.hash()] = PlannerNode.new(successor, current_node, newCost, estimate_cost(successor, desired_state), action)
					$PriorityQueue.insert(visited[successor.hash()])
				else:
					if newCost < visited[successor.hash()].given_cost:
						visited[successor.hash()].given_cost = newCost
						visited[successor.hash()].final_cost = visited[successor].heuristic_cost + newCost
						visited[successor.hash()].parent = current_node
						visited[successor.hash()].action = action
						##will resort queue if present in queue, insert if not
						$PriorityQueue.insert_or_resort(visited[successor.hash()])
	##what should be returned if no solution found?
	return []

func preconditions_met(current_state : Dictionary, action : Node) -> bool:
	for key in action.preconditions.keys():
		if current_state.has(key):
			if current_state[key] != action.preconditions[key]:
				return false
		else:
			return false
	return true

func apply_action_effects(current_state : Dictionary, action : Node) -> Dictionary:
	var new_state = current_state.duplicate()
	for key in action.effects.keys():
		new_state[key] = action.effects[key]
	return new_state

func compare_states(current_state: Dictionary, desired_state: Dictionary) -> bool:
	for key in desired_state.keys():
		if current_state.has(key):
			if desired_state[key] != current_state[key]:
				return false
		else:
			return false
	return true

func get_solution(goal: PlannerNode) -> Array:
	var traceback:PlannerNode = goal
	var solution: Array = []
	while(traceback != null and visited[traceback.state.hash()].action != null):
		solution.push_front(visited[traceback.state.hash()].action)
		traceback = visited[traceback.state.hash()].parent
	
	return solution
