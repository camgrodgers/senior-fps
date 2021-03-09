extends ImmediateGeometry
class_name Tracer

var _from: Vector3
var _to: Vector3
var _running: bool = false
var _timer = .04

var _material = preload("res://textures/bullet_trail_material.tres")

func _ready():
	self.add_to_group("temporary_level_objects")
	self.material_override = _material

func set_coordinates(from: Vector3, to: Vector3) -> void:
	_running = true
	_from = from
	_to = to

func _process(delta):
	if not _running: return
	if _timer < 0:
		self.queue_free()
		return
	
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	set_normal(Vector3(0, 0, 1))
	set_color(Color(1, 0, 0, 0))
	add_vertex(_from)
	set_normal(Vector3(0, 0, 1))
	set_color(Color(0, 0, 1, 1))
	add_vertex(_from + ((_to - _from) / 2))
	set_color(Color(1, 0, 0, 0))
	set_normal(Vector3(0, 0, 1))
	add_vertex(_to)
	end()
	_timer -= delta
