extends Area

var speed = 750
#var velocity = Vector3()

export var muzzle_velocity = 50
export var g = Vector3.DOWN * 1

var velocity = Vector3.ZERO


func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta


func _on_Bullet_body_entered(body):
	if body is StaticBody:
		queue_free()

func _on_Timer_timeout():
	queue_free()



