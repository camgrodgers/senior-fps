extends Navigation

var enemies: Spatial = null
var player: KinematicBody = null

onready var player_scn: Resource = preload("res://Player/Player.tscn")
onready var enemy_scn: Resource = preload("res://Enemies/Enemy.tscn")

func _ready():
	add_instances()

func _physics_process(_delta):
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
	
	for e in $PatrolRoutes.get_children():
		var enemy_instance: KinematicBody = enemy_scn.instance()
		enemies.add_child(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.target = player
		enemy_instance.navNodes = $NavNodes.get_children()
		enemy_instance.translation = get_closest_point(Vector3(e.get_child(0).translation.x, 0, e.get_child(0).translation.z))
		enemy_instance.patrolNodes = e.get_children()
