extends Navigation

var enemies = []
var coverNodes = []
var player

func _ready():
	
	player = load("res://Player/Player.tscn")
	player = player.instance()
	add_child(player)
	player.translation = $PlayerSpawn.translation
	
	
	
	
	for patrol_route in $PatrolRoutes.get_children():
		var enemy = load("res://Enemies/Enemy.tscn")
		var enemy_instance = enemy.instance()
		add_child(enemy_instance)
		enemies.append(enemy_instance)

		enemy_instance.nav = self
		enemy_instance.target = player
		enemy_instance.navNodes = $NavNodes.get_children()
		enemy_instance.translation = get_closest_point(Vector3(patrol_route.get_child(0).translation.x, 0, patrol_route.get_child(0).translation.z))
		enemy_instance.patrolNodes = patrol_route.get_children()
		enemy_instance.coverNodes = coverNodes
		
		for node in patrol_route.get_children():
			node.NODE_TYPE = 'patrol'
	
	for node in $NavNodes.get_children():
		node.NODE_TYPE = 'nav'
	

func _process(delta):
	coverNodes.clear()
	var space_state = get_world().direct_space_state
	var actors = [player]
	actors += enemies
	for n in $NavNodes.get_children():
		for h in player.hitboxes():
			var body_ray = space_state.intersect_ray(h.global_transform.origin, n.global_transform.origin, actors)
			print(n)
			if body_ray.empty():
				print("empty ray")
				# Something very messed up must have happened
				# return an error or something here
				#WHY IS IT EMPTY??? It seems to only be empty when the player can see the node
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
				
