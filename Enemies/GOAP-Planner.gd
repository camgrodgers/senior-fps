extends Node

class Graph_Node:
	var state: Dictionary
	var edges: Array = []
	
	func _init(state):
		self.state = state

class Edge:
	var action: Node
	var end_point: Graph_Node
	var cost: int
	
	func _init(action, end_point, cost):
		self.action = action
		self.end_point = end_point
		self.cost = cost

class PlannerNode:
	var vertex: Graph_Node
	var parent: Graph_Node
	var given_cost: int
	var heuristic_cost: int
	var final_cost: int
	
	func _init(vertex, parent, given_cost, heuristic_cost):
		self.vertex = vertex
		self.parent = parent
		self.given_cost = given_cost
		self.heuristic_cost = heuristic_cost
		self.final_cost = given_cost + heuristic_cost

var start: Graph_Node = null
var goal: Graph_Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	for a in get_children():
#		actions.add_child(a)
	
	
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
func plan_actions(current_state: Dictionary, desired_state: Dictionary):
	
	var open = $PriorityQueue._init()
	open.insert(PlannerNode.new(start, null, 0, estimate_cost(start.state, desired_state)))
	var visited = {start: open.peek()}
	
	while !open.empty():
		var current_node = open.delMin()
		
		if check_if_desired(current_node.vertex.state, desired_state):
			###solved!!!
			goal = current_node
			return true;
		
		for edge in current_node.vertex.edges:
			var newCost = current_node.given_cost + edge.cost
			var successor = edge.end_point
			
			if not visited.has(successor):
				visited[successor] = PlannerNode.new(successor, current_node.vertex, newCost, estimate_cost(successor.state, desired_state))
				open.insert(visited[successor])
			else:
				if newCost < visited[successor].given_cost:
					visited[successor].given_cost = newCost
					visited[successor].final_cost = visited[successor].heuristic_cost + newCost
					visited[successor].parent = current_node.vertex
					##will resort queue if present in queue, insert if not
					open.insert_or_resort(visited[successor])
	
	##what should be returned if no solution found?
	return

func check_if_desired(current_state: Dictionary, desired_state: Dictionary) -> bool:
	for key in desired_state.keys():
		if current_state.has(key):
			if desired_state[key] != current_state[key]:
				return false
		else:
			return false
	return true


##Initialize Generation by creating start node
##Get adjacents of start node
##Put adjacents in queue to visit later
##When pulled off of queue, check if state satisfies desired
##Return the starting node
func generate_graph(current_state: Dictionary, desired_state: Dictionary):
	##Check if a graph even needs to be generated
	##Probably not necessary...
	if check_if_desired(current_state, desired_state):
		return
	
	var solution_count: int = 0
	var queue: Array = []
	var state_in_graph: Dictionary = {}
	start = Graph_Node.new(current_state.duplicate(true))
	state_in_graph[start.state.hash()] = start
	queue.push_back(start)
	
	while(!queue.empty() and solution_count < 5):
		var current:Graph_Node = queue.pop_front()
		if check_if_desired(current.state, desired_state):
			solution_count += 1
			continue
		get_adjacents(current, state_in_graph)
		
		for edge in current.edges:
			queue.push_back(edge.end_point)
	
	return start

##Go through list of actions
##If preconditions met, add an edge with updated state
##Check state against current states in graph to see if duplicate
##Checking for duplicates and properly linking nodes allows for more dynamic planning
func get_adjacents(node: Graph_Node, state_in_graph: Dictionary):
	for action in $Actions.get_children():
		var precons_met: bool = true
		for key in action.preconditions.keys():
			if node.state.has(key):
				if node.state[key] != action.preconditions[key]:
					precons_met = false
					break
			else:
				precons_met = false
				break
		if precons_met:
			var new_state = node.state.duplicate(true)
			for key in action.effects.keys():
				new_state[key] = action.effects[key]
			if state_in_graph.has(new_state.hash):
				node.edges.append(Edge.new(action, state_in_graph[new_state.hash], action.cost))
			else:
				state_in_graph[new_state.hash] = Graph_Node.new(new_state)
				node.edges.append(Edge.new(action, state_in_graph[new_state.hash], action.cost))
