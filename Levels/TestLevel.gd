extends Navigation

var enemies = []
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
		
		for node in patrol_route.get_children():
			node.NODE_TYPE = 'patrol'
	
	for node in $NavNodes.get_children():
		node.NODE_TYPE = 'nav'

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#for e in enemies:
	#	var x = e.translation
