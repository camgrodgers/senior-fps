tool
extends CSGSphere
class_name NavNode

var occupied: bool = false
var NODE_TYPE = null
var occupied_by = null
var visible_to_player: bool = false

func _ready():
	if not Engine.editor_hint:
		visible = false

func _process(delta) -> void:
	if Engine.editor_hint:
		if snap_to_navmesh:
			reposition()

# Tool code
export(bool) var snap_to_navmesh = true
var nav: Navigation = null
var last_translation: Vector3 = self.translation
func reposition() -> void:
	if translation == last_translation:
		return
	
	last_translation = translation
	
	if nav == null:
		var maybe_nav = get_tree().get_nodes_in_group("navigation")
		maybe_nav = maybe_nav[0]
		if maybe_nav is Navigation:
			nav = maybe_nav
		else:
			print("NavNode not related to nav")
			return
		
	var snap_point: Vector3 = nav.get_closest_point(global_transform.origin)
	snap_point.y += 1
	global_transform.origin = snap_point

