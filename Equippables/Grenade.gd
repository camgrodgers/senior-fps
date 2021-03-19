extends RigidBody
class_name GRENADE


var grenadeTime = 4
var grenadeTimer = 0
var explosionTime = 1
var explosionTimer  = 0

var grenade;
var explosionArea
var explosionParticles



func _ready():
	grenade = $MeshInstance;
	explosionArea = $ExplosionArea
	explosionParticles = $ExplosionParticles
	
	explosionParticles.emitting = false
	explosionParticles.one_shot = true
	
	

func _process(delta):
	if grenadeTimer < grenadeTime:
		grenadeTimer += delta
		return
	else:
		explosionParticles.emitting = true
		grenade.visible = false
		var objects = explosionArea.get_overlapping_bodies ()
		for object in objects:
			if object.has_method("take_damage"):
				object.take_damage()
		if explosionTimer < explosionTime:
			explosionTimer += delta
		else:
			queue_free()
				
		
		
	



