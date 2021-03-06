extends Node

#class Graph_Node:
#	var state: Dictionary
#	var edges: Array = []
#
#	func _init(state):
#		self.state = state
#
#class Edge:
#	var action: Node
#	var end_point: Graph_Node
#	var cost: int
#
#	func _init(action, end_point, cost):
#		self.action = action
#		self.end_point = end_point
#		self.cost = cost

#class PlannerNode:
#	var vertex: Graph_Node
#	var parent: Graph_Node
#	var edge: Edge
#	var given_cost: int
#	var heuristic_cost: int
#	var final_cost: int
#
#	func _init(vertex, parent, given_cost, heuristic_cost, edge):
#		self.vertex = vertex
#		self.parent = parent
#		self.given_cost = given_cost
#		self.heuristic_cost = heuristic_cost
#		self.final_cost = given_cost + heuristic_cost
#		self.edge = edge

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
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

##Returning first child as placeholder
##Use A* to go through search graph
##Get a list of actions to follow
#func plan_actions(current_state: Dictionary):
#
#	current_goal = get_goal_node(current_state)
#	var desired_state: Dictionary = current_goal.desired_state
#	var start: Graph_Node = generate_graph(current_state, desired_state)
#	if start == null:
#		##No actions needed, should not happen
#		return []
#
#	$PriorityQueue._init()
#	$PriorityQueue.insert(PlannerNode.new(start, null, 0, estimate_cost(start.state, desired_state), null))
#	visited = {start: $PriorityQueue.peek()}
#
#	while !$PriorityQueue.empty():
#		var current_node = $PriorityQueue.delMin()
#
#		if compare_states(current_node.vertex.state, desired_state):
#			###solved!!!
#			var goal: Graph_Node = current_node.vertex
#			return get_solution(goal);
#
#		for edge in current_node.vertex.edges:
#			var newCost = current_node.given_cost + edge.cost
#			var successor = edge.end_point
#
#			if not visited.has(successor):
#				visited[successor] = PlannerNode.new(successor, current_node.vertex, newCost, estimate_cost(successor.state, desired_state), edge)
#				$PriorityQueue.insert(visited[successor])
#			else:
#				if newCost < visited[successor].given_cost:
#					visited[successor].given_cost = newCost
#					visited[successor].final_cost = visited[successor].heuristic_cost + newCost
#					visited[successor].parent = current_node.vertex
#					visited[successor].edge = edge
#					##will resort queue if present in queue, insert if not
#					$PriorityQueue.insert_or_resort(visited[successor])
#
#	##what should be returned if no solution found?
#	return []

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
						visited[successor.hash()].parent = current_node.vertex
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
##Initialize Generation by creating start node
##Get adjacents of start node
##Put adjacents in queue to visit later
##When pulled off of queue, check if state satisfies desired
##Return the starting node
#func generate_graph(current_state: Dictionary, desired_state: Dictionary) -> Graph_Node:
#	##Check if a graph even needs to be generated
#	##Probably not necessary...
#	if compare_states(current_state, desired_state):
#		return null
#
#	var solution_count: int = 0
#	var queue: Array = []
#	var state_in_graph: Dictionary = {}
#	var start : Graph_Node = Graph_Node.new(current_state.duplicate(true))
#	state_in_graph[start.state.hash()] = start
#	queue.push_back(start)
#
#	while(!queue.empty() and solution_count < 5):
#		var current:Graph_Node = queue.pop_front()
#		if compare_states(current.state, desired_state):
#			solution_count += 1
#			continue
#		get_adjacents(current, state_in_graph)
#
#		for edge in current.edges:
#			queue.push_back(edge.end_point)
#
#	return start

##Go through list of actions
##If preconditions met, add an edge with updated state
##Check state against current states in graph to see if duplicate
##Checking for duplicates and properly linking nodes allows for more dynamic planning
#func get_adjacents(node: Graph_Node, state_in_graph: Dictionary):
#	for action in $Actions.get_children():
#		var precons_met: bool = true
#		for key in action.preconditions.keys():
#			if node.state.has(key):
#				if node.state[key] != action.preconditions[key]:
#					precons_met = false
#					break
#			else:
#				precons_met = false
#				break
#		if precons_met:
#			var new_state = node.state.duplicate(true)
#			for key in action.effects.keys():
#				new_state[key] = action.effects[key]
#			if state_in_graph.has(new_state.hash()):
#				node.edges.append(Edge.new(action, state_in_graph[new_state.hash()], action.cost))
#			else:
#				state_in_graph[new_state.hash()] = Graph_Node.new(new_state)
#				node.edges.append(Edge.new(action, state_in_graph[new_state.hash()], action.cost))


