extends Navigation

var enemies: Spatial = null
var player: KinematicBody = null

func _ready():
	var player_scn: Resource = load("res://Player/Player.tscn")
	player = player_scn.instance()
	self.add_child(player)
	player.translation = $PlayerSpawn.translation
	
	enemies = Spatial.new()
	self.add_child(enemies)
	
	for e in $PatrolRoutes.get_children():
		var enemy: Resource = load("res://Enemies/Enemy.tscn")
		var enemy_instance: KinematicBody = enemy.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.target = player
		enemy_instance.navNodes = $NavNodes.get_children()
		enemy_instance.translation = get_closest_point(Vector3(e.get_child(0).translation.x, 0, e.get_child(0).translation.z))
		enemy_instance.patrolNodes = e.get_children()
