extends Area
class_name SpawnTrigger

onready var signals: Signals = get_node("/root/Signals")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")

export(bool) var deactivate_when_triggered = true

var triggered: bool = false

func _ready():
	signals.connect("restart_level", self, "_on_restart_level")
	connect("body_entered", self, "_on_SpawnTrigger_body_entered")
#	connect("area_entered", self, "_on_SpawnTrigger_body_entered")

func _on_SpawnTrigger_body_entered(body):
	if triggered: return
	if not body is Player: return
	
	for s in get_children():
		if s is EnemySpawn:
			signals.emit_signal("enemy_spawn_triggered",
				s.global_transform.origin,
				s.enemy_type,
				null,
				true)
		elif s is PatrolRoute:
			var spawn_location = s.get_children()[0].global_transform.origin
			signals.emit_signal("enemy_spawn_triggered",
				spawn_location,
				s.enemy_type,
				s.get_children(),
				false)
		else:
			pass

	if deactivate_when_triggered:
		triggered = true

func _on_restart_level():
	triggered = false
