extends Spatial

export var game_over_shot = preload("res://Sounds/Game_Over_shot.wav")
export var rifle_shot = preload("res://Sounds/Rifle_shot.wav")
export var gun_cock = preload("res://Sounds/Gun_cock.wav")
var audio_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_node = $Audio_Stream_Player
	audio_node.stop()


func play_sound(audio_stream_name, position=null):

	if audio_stream_name == null:
		print ("Audio not set!")
		return


	audio_node.stream = audio_stream_name
#	else:
#		print ("UNKNOWN STREAM")
#		queue_free()
#		return

	# If you are using an AudioStreamPlayer3D, then uncomment these lines to set the position.
	#if audio_node is AudioStreamPlayer3D:
	#    if position != null:
	#        audio_node.global_transform.origin = position

	audio_node.play()


func destroy_self():
	audio_node.stop()
	queue_free()
