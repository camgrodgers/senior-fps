extends Area
class_name SpawnTrigger

onready var signals: Signals = get_node("/root/Signals")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")

export(bool) var deactivate_when_triggered = true

var triggered: bool = false

func _ready():
	signals.connect("restart_level", self, "_on_restart_level")

func _on_SpawnTrigger_body_entered(body):
	if triggered: return
	if not body is Player: return
	
	var enemies: Array = []
	for s in get_children():
		if not s is EnemySpawn: continue
		
		signals.emit_signal("enemy_spawn_triggered",
			s.global_transform.origin,
			s.enemy_type)

	if deactivate_when_triggered:
		triggered = true

func _on_restart_level():
	triggered = false
