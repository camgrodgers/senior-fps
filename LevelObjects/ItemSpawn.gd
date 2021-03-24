extends Spatial
class_name ItemSpawn

onready var signals = get_node("/root/Signals")
export(String, "AK47", "Glock18", "Sniper") var item_type = "Glock18"

func _ready():
	visible = false

func spawn_item():
	var scene
	if item_type == "AK47":
		scene = preload("res://Equippables/AK47ItemDrop.tscn")
	elif item_type == "Glock18":
		scene = preload("res://Equippables/Glock18ItemDrop.tscn")
	elif item_type == "Sniper":
		scene = preload("res://Equippables/SNIPERItemDrop.tscn")
	else:
		return
	
	var item = scene.instance()
	item.global_transform = self.global_transform
	item.translation.y += 0.5
	
	signals.emit_signal("temporary_object_spawned", item)

