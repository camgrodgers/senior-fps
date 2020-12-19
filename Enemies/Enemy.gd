extends KinematicBody


var nav: Navigation = null
var target = null
var path: Array = []
var progress: float = 0

func _ready():
	pass
	
func prep():
	path = nav.get_simple_path(translation, target.translation, true)
	path = Array(path)
	for p in path:
		p.y = translation.y

func _process(delta):
#	path = nav.get_simple_path(translation, target.translation, true)
#	path = Array(path)
#	print(path)
#	for p in path:
#		var sphere: CSGSphere = CSGSphere.new()
#		sphere.set_name("asdf")
#		get_parent().add_child(sphere)
#
#		sphere.translation = p
#	progress += delta * .5
#	print(progress)
#	self.translation = path[round(progress)]
	
	if path.size() < 1:
		prep()
	var speed = 4.0
	var moving = speed * delta
	var to = path[0]
	var distance = translation.distance_to(to)
	if distance < moving:
		path.pop_front()
		return
	
	translation = translation.linear_interpolate(to, moving / distance)
	
	
func take_damage():
	print("asdf")
	self.queue_free()

