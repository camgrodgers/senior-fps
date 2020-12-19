extends Navigation



func _ready():
	var enemies = []
	enemies.append($Enemy)
	enemies.append($Enemy2)
#	enemies.append($Enemy3)
	for e in enemies:
		e.nav = self
		e.target = $Player
		e.prep()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
