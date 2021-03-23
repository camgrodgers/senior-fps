tool
extends CSGSphere
class_name NavNode


func _ready():
	if not Engine.editor_hint:
		_game_ready()

func _process(delta) -> void:
	if Engine.editor_hint:
		if snap_to_navmesh:
			reposition()

# Game code
const NOT_SEEN_BY_PLAYER_GROUP: String = "navnodes_not_seen_by_player"
const SEEN_BY_PLAYER_GROUP: String = "navnodes_seen_by_player"

var occupied: bool = false
var occupied_by = null
var visible_to_player: bool = false

func _game_ready():
	self.visible = false
	_update_groups()

func mark_occupied(occupier):
	occupied = true
	occupied_by = occupier
	_update_groups()

func mark_not_occupied():
	occupied = false
	occupied_by = null
	_update_groups()

func mark_visible():
	visible_to_player = true
	_update_groups()

func mark_not_visible():
	visible_to_player = false
	_update_groups()

func _update_groups():
	_remove_from_groups()
	if occupied:
		return

	if visible_to_player:
		add_to_group(SEEN_BY_PLAYER_GROUP)
	else:
		add_to_group(NOT_SEEN_BY_PLAYER_GROUP)

func _remove_from_groups():
	if is_in_group(NOT_SEEN_BY_PLAYER_GROUP):
		remove_from_group(NOT_SEEN_BY_PLAYER_GROUP)
	if is_in_group(SEEN_BY_PLAYER_GROUP):
		remove_from_group(SEEN_BY_PLAYER_GROUP)

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

