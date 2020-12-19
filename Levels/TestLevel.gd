extends Navigation

onready var enemy = $Enemy

func _ready():
	enemy.nav = self
	enemy.target = $Player
	enemy.prep()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
