extends CSGBox

var is_white: bool = false

func interact():
	if is_white:
		material.albedo_color = Color(0,0,0)
		is_white = false
	else:
		material.albedo_color = Color(255,255,255)
		is_white = true
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
