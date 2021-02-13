extends Spatial

var game_over_shot = preload("res://Sounds/Sniper_shot.wav")
var audio_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_node = $Audio_Stream_Player
	audio_node.connect("finished", self, "destroy_self")
	audio_node.stop()
	pass # Replace with function body.


func play_sound(sound_name, position=null):

	if game_over_shot == null:
		print ("Audio not set!")
		queue_free()
		return

	if sound_name == "Game_Over_shot":
		audio_node.stream =game_over_shot
	else:
		print ("UNKNOWN STREAM")
		queue_free()
		return

	# If you are using an AudioStreamPlayer3D, then uncomment these lines to set the position.
	#if audio_node is AudioStreamPlayer3D:
	#    if position != null:
	#        audio_node.global_transform.origin = position

	audio_node.play()


func destroy_self():
	audio_node.stop()
	queue_free()
