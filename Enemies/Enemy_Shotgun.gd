extends Enemy

func _init():
	MAX_HP = 3.0
	ENEMY_RANGE = 30.0
	_shoot_interval = 4.0
	DAMAGE_MULTIPLIER = 1.5
	
func _ready():
	$Enemy_audio_player.enemy_shot = preload("res://Sounds/Shotgun_shot.wav")
