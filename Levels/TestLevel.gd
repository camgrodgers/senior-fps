extends Navigation
class_name Level

var enemies: Spatial = null
var player: KinematicBody = null
var coverNodes = []

onready var player_scn: Resource = preload("res://Player/Player.tscn")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")

func _ready():
	add_instances()
	update_cover()

func _process(delta):
	if enemies.get_child_count() == 0:
		spawn_enemies()
	update_cover()
	# NOTE: it might make sense to replace this bool flag with a signal
	if not(player.is_dead and Input.is_action_pressed("jump")):
		return
#	max_enemies_counter = 0
	
	remove_child(enemies)
	enemies.queue_free()
	
	remove_child(player)
	player.queue_free()
	
	add_instances()
	update_cover()
	
func spawn_enemies():
	var i: int = 0
	var spawns: Array = $EnemySpawns.get_children()
	spawns.shuffle()
	for spawn in spawns:
		var enemy_instance: KinematicBody = enemy_scn.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.state = 3
		enemy_instance.target = player
		enemy_instance.player = player
		enemy_instance.translation = get_closest_point(Vector3(spawn.translation.x, 0, spawn.translation.z))
		enemy_instance.patrolNodes = $PatrolRoutes.get_child(0).get_children()
		enemy_instance.coverNodes = coverNodes
		i += 1
#		if i == round(max_enemies_counter): return
		

func add_instances():
	player = player_scn.instance()
	self.add_child(player)
	player.translation = $PlayerSpawn.translation
	
	
	enemies = Spatial.new()
	self.add_child(enemies)
	
	for patrol_route in $PatrolRoutes.get_children():
		var enemy_instance: KinematicBody = enemy_scn.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.target = player
		enemy_instance.player = player
		enemy_instance.translation = get_closest_point(Vector3(patrol_route.get_child(0).translation.x, 0, patrol_route.get_child(0).translation.z))
		enemy_instance.patrolNodes = patrol_route.get_children()
		enemy_instance.coverNodes = coverNodes
		
	for node in $NavNodes.get_children():
		node.NODE_TYPE = 'nav'
		node.occupied = false
	
	update_cover()

# TODO: This could possibly be improved by moving it into the player and
# 		having a front vision, flanking, and rear area that detect nodes
func update_cover():
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
