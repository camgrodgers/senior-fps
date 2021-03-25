tool
extends SnapToTerrain
class_name EnemySpawn

export(String, "prototype", "shotgun", "sniper", "rifle", "pistol") var enemy_type = ""

func _ready():
	if Engine.editor_hint:
		return
	visible = false
	$EnemySpawn.use_collision = false
