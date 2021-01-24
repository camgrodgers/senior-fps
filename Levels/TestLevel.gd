extends Navigation

enum {
	FIND,
	HOLD,
	PATROL
}
##ENEMY ENUM INCLUDED FOR TESTING IN ORDER TO DIRECTLY ASSIGN STATE

func _ready():
	var enemies = []
	enemies.append($Enemy)
	enemies.append($Enemy2)
#	enemies.append($Enemy3)
	
	var nodes = []
	nodes.append($NavNode)
	nodes.append($NavNode2)
	nodes.append($NavNode3)
	nodes.append($NavNode4)
	
	var patrol_nodes = []
	patrol_nodes.append($PatrolNode1)
	patrol_nodes.append($PatrolNode2)
	patrol_nodes.append($PatrolNode3)
	
	for e in enemies:
		e.nav = self
		e.target = $Player
		e.navNodes = nodes
		e.numNodes = nodes.size()
	
	enemies[0].patrolNodes = patrol_nodes
	enemies[0].state = PATROL


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
