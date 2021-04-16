extends AnimationPlayer

func _process(delta):
	if not is_playing():
		play()
