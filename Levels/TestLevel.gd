extends Navigation

enum {
	FIND,
	HOLD,
	PATROL
}
##ENEMY ENUM INCLUDED FOR TESTING IN ORDER TO DIRECTLY ASSIGN STATE

var enemies = []
var player

func _ready():
	
	
	
	
	
	player = load("res://Player/Player.tscn")
	player = player.instance()
	add_child(player)
	player.translation = $PlayerSpawn.translation
	
	
	
	
	for e in $PatrolRoutes.get_children():
		var enemy = load("res://Enemies/Enemy.tscn")
		var enemy_instance = enemy.instance()
		add_child(enemy_instance)
		enemies.append(enemy_instance)
		
		enemy_instance.nav = self
		enemy_instance.target = player
		enemy_instance.navNodes = $NavNodes.get_children()
		enemy_instance.translation = e.get_child(0).translation
		enemy_instance.patrolNodes = e.get_children()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for e in enemies:
		var x = e.translation
