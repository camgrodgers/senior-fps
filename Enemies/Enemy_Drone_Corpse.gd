extends KinematicBody

var rearm_enemies_timer = 0.0

func _process(delta):
	rearm_enemies_timer += delta
	if rearm_enemies_timer > 8.0:
		get_tree().call_group("enemies", "drone_ready")
		self.queue_free()
