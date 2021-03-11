extends Navigation
class_name Level

onready var signals: Signals = get_node("/root/Signals")

onready var player_scn: Resource = preload("res://Player/Player.tscn")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")

var coverNodes: Array = []
var enemies: Spatial = null
var player: Player = null
var temporary_nodes: Spatial = Spatial.new()

func _init():
	self.add_to_group("level")
	add_child(temporary_nodes)
	signals.connect("temporary_item_spawned",
			self,
			"_on_temporary_item_spawned")

# TODO: This could possibly be improved by moving it into the player and
# 		having a front vision, flanking, and rear area that detect nodes
func update_cover() -> void:
	coverNodes.clear()
	var space_state = get_world().direct_space_state
#	var actors = [player]
#	actors += enemies.get_children()
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
			print("empty ray")
			# This was empty because the navnode collision was disabled,
			# now, this path should not execute.
			n.visible_to_player = true
			continue
			
		var collider = body_ray.collider
#			print(collider)
		if collider == n:
			n.visible_to_player = true
			
		else:
#			if coverNodes.has(n):
#				continue
			coverNodes.append(n)
			n.visible_to_player = false

func spawn_scene(scene: Resource, spawn_pos: Vector3, parent: Node) -> Node:
	var instance = scene.instance()
	parent.add_child(instance)
	instance.translation = spawn_pos
	return instance

func spawn_enemy(spawn_pos: Vector3, state: int, patrol_route: Array) -> void:
	var instance: Enemy = spawn_scene(enemy_scn, spawn_pos, enemies)
	instance.nav = self
	instance.state = state
	instance.player = player
	instance.patrolNodes = patrol_route
	instance.coverNodes = coverNodes

func _on_temporary_object_spawned(obj):
	temporary_nodes.add_child(obj)
