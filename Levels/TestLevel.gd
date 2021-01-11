extends Navigation



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
	
	for e in enemies:
		e.nav = self
		e.target = $Player
		e.navNodes = nodes
		e.numNodes = nodes.size()
		e.prep()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
