extends Node

class Graph_Node:
	var state: Dictionary
	var edges: Array = []

class Edge:
	var action: Node
	var end_point: Graph_Node
	var current_cost: int

var start: Graph_Node = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	for a in get_children():
#		actions.add_child(a)
	
##Returning first child as placeholder
func plan_actions(current_state: Dictionary, desired_state: Dictionary):
	
	
	return get_child(0)

func check_if_desired(current_state: Dictionary, desired_state: Dictionary) -> bool:
	var states_equal: bool = true
	for key in desired_state.keys():
		if current_state.has(key):
			if desired_state[key] != current_state[key]:
				states_equal = false
				break
		else:
			states_equal = false
			break
	return states_equal


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
	var start = Graph_Node.new()
	start.state = current_state.duplicate(true)
	queue.push_back(start)
	
	while(!queue.empty() and solution_count < 5):
		var current:Graph_Node = queue.pop_front()
		if check_if_desired(current.state, desired_state):
			solution_count += 1
			continue
		get_adjacents(current)
		
		for edge in current.edges:
			queue.push_back(edge.end_point)
	
	return start

##Go through list of actions
##If preconditions met, add an edge with updated state
func get_adjacents(node: Graph_Node):
	for action in get_children():
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
			var add_edge = Edge.new()
			add_edge.action = action
			add_edge.end_point = Graph_Node.new()
			add_edge.end_point.state = new_state
			add_edge.current_cost = action.cost
			node.edges.append(add_edge)
