extends Navigation
class_name Level

onready var signals: Signals = get_node("/root/Signals")

onready var player_scn: Resource = preload("res://Player/Player.tscn")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")
onready var enemy_shotgun_scn: Resource = preload("res://Enemies/Enemy_Shotgun.tscn")


var rng = RandomNumberGenerator.new()

var enemies: Spatial = null
var player: Player = null
var temporary_nodes: Spatial = Spatial.new()

func _init():
	self.add_to_group("level")
	add_child(temporary_nodes)

func _ready():
	signals.connect("enemy_spawn_triggered",
			self,
			"_on_enemy_spawn_triggered")
	signals.connect("temporary_object_spawned",
			self,
			"_on_temporary_object_spawned")

# TODO: This could possibly be improved by moving it into the player and
# 		having a front vision, flanking, and rear area that detect nodes
func update_cover() -> void:
	var space_state = get_world().direct_space_state
	var h = player.hitboxes()[0]
	for n in get_tree().get_nodes_in_group("navnodes"):
		var body_ray = space_state.intersect_ray(
			h.global_transform.origin,
			n.global_transform.origin,
			[], # exclude
			0b100001, # collides with 0...0,navnodes, 0, 0, 0, 0, world
			true, # collide with bodies  
			false) # collide with areas
		if body_ray.empty():
			# This was empty because the navnode collision was disabled,
			# now, this path should not execute.
			n.mark_visible()
			continue
			
		var collider = body_ray.collider
		if collider == n:
			n.mark_visible()
			
		else:
			n.mark_not_visible()

func spawn_enemy(spawn_pos: Vector3, enemy_type: String) -> void:
	
	var enemy_instance = enemy_scn.instance()
	enemies.add_child(enemy_instance)
	
	enemy_instance.nav = self
	enemy_instance.replan_actions()
	enemy_instance.player = player
	enemy_instance.translation = get_closest_point(spawn_pos)
	enemy_instance.patrolNodes = $PatrolRoutes.get_child(0).get_children()

func _on_temporary_object_spawned(obj):
	temporary_nodes.add_child(obj)

func _on_enemy_spawn_triggered(location: Vector3, enemy_type: String) -> void:
	spawn_enemy(location, enemy_type)

