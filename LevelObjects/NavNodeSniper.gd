tool
extends CSGSphere
class_name NavNodeSniper


func _ready():
	if not Engine.editor_hint:
		_game_ready()

func _process(delta) -> void:
	if Engine.editor_hint:
		if snap_to_navmesh:
			reposition()

# Game code
var occupied: bool = false
var occupied_by = null

func _game_ready():
	self.visible = false

func mark_occupied(occupier):
	occupied = true
	occupied_by = occupier

func mark_not_occupied():
	occupied = false
	occupied_by = null

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
#	print(snap_point)
	global_transform.origin.y = snap_point.y

