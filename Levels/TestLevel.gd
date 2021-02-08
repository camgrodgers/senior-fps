extends Navigation

var enemies: Spatial = null
var player: KinematicBody = null
var coverNodes = []

onready var player_scn: Resource = preload("res://Player/Player.tscn")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")

func _ready():
	add_instances()

func _physics_process(delta):
	update_cover()
	# NOTE: it might make sense to replace this bool flag with a signal
	if not(player.is_dead and Input.is_action_pressed("jump")):
		return
	
	remove_child(enemies)
	enemies.queue_free()
	
	remove_child(player)
	player.queue_free()
	
	add_instances()

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
		enemy_instance.patrolNodes = $NavNodes.get_children()
		enemy_instance.coverNodes = coverNodes
		
	for node in $NavNodes.get_children():
		node.NODE_TYPE = 'nav'
	
	update_cover()

func update_cover():
	coverNodes.clear()
	var space_state = get_world().direct_space_state
	var actors = [player]
	actors += enemies.get_children()
	for n in $NavNodes.get_children():
		for h in player.hitboxes():
			var body_ray = space_state.intersect_ray(h.global_transform.origin, n.global_transform.origin, actors)
			print(n)
			if body_ray.empty():
				print("empty ray")
				# Something very messed up must have happened
				# return an error or something here
				#WHY IS IT EMPTY??? It seems to only be empty when the player can see the node
				#and an enemy is in the way...sometimes
				#setting it as true until I figure out what is happening
				n.visible_to_player = true
				continue
				
			var collider = body_ray.collider
			print(collider)
			if collider == n:
				n.visible_to_player = true
				
			else:
				coverNodes.append(n)
				n.visible_to_player = false
