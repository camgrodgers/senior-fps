extends Level

func _ready():
	add_instances()

func _custom_level_process(delta):
	if enemies.get_child_count() == 0:
		spawn_enemies()


func _custom_level_restart():
	add_instances()


func spawn_enemies():
	var spawns: Array = $EnemySpawns.get_children()
	spawns.shuffle()
	for spawn in spawns:
		rng.randomize()
		var random_number = rng.randf_range(0.0, 1.0)
		var enemy_instance: KinematicBody = null
		if random_number > 0.8:
			enemy_instance = enemy_shotgun_scn.instance()
		else:
			enemy_instance = enemy_scn.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.replan_actions()
		enemy_instance.player = player
		enemy_instance.translation = get_closest_point(Vector3(spawn.translation.x, 0, spawn.translation.z))
		enemy_instance.patrolNodes = $PatrolRoutes.get_child(0).get_children()
		

func add_instances():
	for patrol_route in $PatrolRoutes.get_children():
		rng.randomize()
		var random_number = rng.randf_range(0.0, 1.0)
		var enemy_instance: KinematicBody = null
		if random_number > 0.8:
			enemy_instance = enemy_shotgun_scn.instance()
		else:
			enemy_instance = enemy_scn.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.player = player
		enemy_instance.translation = get_closest_point(Vector3(patrol_route.get_child(0).translation.x, 0, patrol_route.get_child(0).translation.z))
		enemy_instance.patrolNodes = patrol_route.get_children()

