tool
extends Spatial
class_name PatrolRoute

export(bool) var loop: bool = true
export(String, "prototype", "shotgun", "sniper", "rifle", "pistol") var enemy_type = ""


func _ready():
	if Engine.editor_hint:
		tool_ready()

func _process(delta):
	if Engine.editor_hint:
		tool_process(delta)
	else:
		game_process(delta)

var occupied: bool = false

func game_process(delta: float) -> void:
	pass



# Editor tool code
var loop_last_value: bool = true
func tool_process(delta: float) -> void:
	if children_count < get_child_count():
		connect_child_moved_signal()
		draw_lines()
		children_count = get_child_count()
	if children_count > get_child_count():
		children_count = get_child_count()
		draw_lines()
	if loop_last_value != loop:
		draw_lines()
		loop_last_value = loop

func tool_ready():
	im = ImmediateGeometry.new()
	add_child(im)
	draw_lines()
	children_count = get_child_count()
	connect_child_moved_signal()
	loop_last_value = loop

func connect_child_moved_signal():
	for c in get_children():
		if c is PatrolNode:
			if c.is_connected("moved", self, "_on_child_moved"):
				continue
			c.connect("moved", self, "_on_child_moved")

func _on_child_moved():
	draw_lines()

func _exit_tree():
	if im != null:
		im.clear()
		im.queue_free()

var im: ImmediateGeometry = null
var children_count: int = 0
func draw_lines():
	if im == null:
		im = ImmediateGeometry.new()
		add_child(im)
	
	im.clear()
	im.begin(Mesh.PRIMITIVE_LINE_LOOP if loop else Mesh.PRIMITIVE_LINE_STRIP)
	for p in get_children():
		if p is PatrolNode:
			im.set_normal(Vector3(0, 0, 1))
			im.add_vertex(p.translation)
	
	im.end()
