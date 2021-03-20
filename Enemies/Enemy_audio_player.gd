extends Spatial


export var enemy_shot = preload("res://Sounds/Rifle_shot.wav")
export var gun_cock = preload("res://Sounds/Gun_cock.wav")
var movement = null
var destruction_alert = null
var audio_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_node = $AudioStreamPlayer3D
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
	if audio_node is AudioStreamPlayer3D:
		if position != null:
			audio_node.global_transform.origin = position

	audio_node.play()

func playing():
	return audio_node.playing

func destroy_self():
	audio_node.stop()
	queue_free()
