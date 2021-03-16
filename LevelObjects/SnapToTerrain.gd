tool
extends Spatial
class_name SnapToTerrain

export(bool) var snap = true


func _process(delta) -> void:
	if Engine.editor_hint:
		if snap:
			reposition()

# Tool code
var last_translation: Vector3 = self.translation
func reposition() -> void:
	if translation == last_translation:
		return
	last_translation = translation
	
	var space_state = get_world().direct_space_state
	var to = global_transform.origin
	to.y -= 1
	var ray = space_state.intersect_ray(
			global_transform.origin,
			to,
			[self], # exclude
			0b0001, # collides with 0, 0, 0, 0, world
			true, # collide with bodies  
			false) # collide with areas
	if ray.empty(): return
	
	var snap_point: Vector3 = ray.position
	global_transform.origin = snap_point
