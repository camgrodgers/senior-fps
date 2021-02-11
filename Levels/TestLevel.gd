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

var enemy_spawn_counter = 0

func _process(delta):
	enemy_spawn_counter += delta
	print(enemies.get_child_count())
#	if enemy_spawn_counter > 30:
#		enemy_spawn_counter = 0
#		spawn_enemies()
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

func update_cover():
	coverNodes.clear()
	var space_state = get_world().direct_space_state
	var actors = [player]
	actors += enemies.get_children()
	var h = player.hitboxes()[0]
	for n in $NavNodes.get_children():
#		for h in player.hitboxes():
		var body_ray = space_state.intersect_ray(h.global_transform.origin, n.global_transform.origin, actors)
#			print(n)
		if body_ray.empty():
#				print("empty ray")
			# Something very messed up must have happened
			# return an error or something here
			#WHY IS IT EMPTY??? It seems to only be empty when the player can see the node
			#and an enemy is in the way...sometimes
			#setting it as true until I figure out what is happening
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
