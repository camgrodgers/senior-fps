extends Navigation

var enemies: Spatial = null
var player: KinematicBody = null

var player_scn: Resource = null
var enemy_scn: Resource = null

func _ready():
	load_scenes()
	add_instances()

func _physics_process(delta):
	# NOTE: it might make sense to replace this bool flag with a signal
	if not player.is_dead:
		return
	
	# TODO: Prompt for input for respawn like hotline miami does 
#	if not Input.
#		return
	
	for e in enemies.get_children():
		enemies.remove_child(e)
		e.queue_free()
	
	remove_child(player)
	player.queue_free()
	
	add_instances()

func load_scenes():
	enemy_scn = load("res://Enemies/Enemy.tscn")
	player_scn = load("res://Player/Player.tscn")

func add_instances():
	player = player_scn.instance()
	self.add_child(player)
	player.translation = $PlayerSpawn.translation
	
	enemies = Spatial.new()
	self.add_child(enemies)
	
	for e in $PatrolRoutes.get_children():
		var enemy_instance: KinematicBody = enemy_scn.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.target = player
		enemy_instance.navNodes = $NavNodes.get_children()
		enemy_instance.translation = get_closest_point(Vector3(e.get_child(0).translation.x, 0, e.get_child(0).translation.z))
		enemy_instance.patrolNodes = e.get_children()
