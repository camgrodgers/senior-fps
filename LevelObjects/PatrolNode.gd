tool
extends CSGSphere
class_name PatrolNode

signal moved

# Length of time enemy should stop on node
export var time_in_seconds: float = 1.0

var occupied: bool = false
var occupied_by = null

# TODO: Fix logic so these patrol nodes are not treated the same as NavNodes
var visible_to_player: bool = true

func _ready() -> void:
	if not Engine.editor_hint:
		visible = false
		use_collision = false

func _process(delta) -> void:
	if Engine.editor_hint:
		reposition(delta)

var nav: Navigation = null
var last_translation: Vector3 = self.translation
var reposition_timer: float = 10.0
var repositioning: bool = false
func reposition(delta: float) -> void:
#	var a = 4
	if translation != last_translation:
		emit_signal("moved")
		reposition_timer = 10.0
		repositioning = true
		last_translation = translation
	
	if not repositioning: return
	
	reposition_timer -= delta
	if reposition_timer <= 0:
		repositioning = false
		
		if nav == null:
			# NOTE/TODO: This is ugly and bad? How should this be fixed?
			var maybe_nav = get_tree().get_nodes_in_group("navigation")
			maybe_nav = maybe_nav[0]
			if maybe_nav is Navigation:
				nav = maybe_nav
			else:
				print("PatrolNode not related to nav")
				return
		
		var snap_point: Vector3 = nav.get_closest_point(global_transform.origin)
		snap_point.y += 1
		global_transform.origin.y = snap_point.y
		emit_signal("moved")
