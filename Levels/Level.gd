extends Navigation
class_name Level

onready var signals: Signals = get_node("/root/Signals")

onready var player_scn: Resource = preload("res://Player/Player.tscn")
onready var enemy_rifle_scn: Resource = preload("res://Enemies/Enemy_Rifle.tscn")
onready var drone: Resource = preload("res://Enemies/Enemy_Drone.tscn")
onready var enemy_shotgun_scn: Resource = preload("res://Enemies/Enemy_Shotgun.tscn")
onready var enemy_pistol_scn: Resource = preload("res://Enemies/Enemy_Pistol.tscn")
onready var enemy_sniper_scn: Resource = preload("res://Enemies/Enemy_Sniper.tscn")


var rng = RandomNumberGenerator.new()

var enemies: Spatial = Spatial.new()
var player: Player = null
var temporary_nodes: Spatial = Spatial.new()

var time_in_level: float = 0
var lower_time_better: bool = true

func _init():
	self.add_to_group("level")
	add_child(temporary_nodes)
	add_child(enemies)

func _ready():
	signals.connect("enemy_spawn_triggered",
			self,
			"_on_enemy_spawn_triggered")
	signals.connect("temporary_object_spawned",
			self,
			"_on_temporary_object_spawned")
	signals.connect("restart_level", self, "_on_restart_level")
	
	_spawn_player()
	_spawn_items()
	_update_cover()

func _process(delta):
	time_in_level += delta
	_update_cover()
	_custom_level_process(delta)
	# NOTE: it might make sense to replace this bool flag with a signal
	if not(player.is_dead and Input.is_action_pressed("jump")):
		return
	
	signals.emit_signal("restart_level")

# Overrideable method
func _custom_level_process(delta) -> void:
	pass

# Overrideable method
func _custom_level_restart() -> void:
	pass

func _on_restart_level():
	_teardown_level()
	_spawn_player()
	_spawn_items()
	_custom_level_restart()
	_update_cover()

func _teardown_level():
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("temporary_level_objects", "queue_free")
	player.queue_free()

func _spawn_items():
	for s in get_tree().get_nodes_in_group("item_spawns"):
		s.spawn_item()

func _spawn_player():
	player = player_scn.instance()
	self.add_child(player)
	player.translation = $PlayerSpawn.translation
	player.get_node("CameraHolder").rotation.y = $PlayerSpawn.rotation.y

func _spawn_enemy(spawn_pos: Vector3,
					enemy_type: String,
					patrol_route,
					has_target: bool = false) -> void:
	var enemy_instance
	if enemy_type == "rifle":
		enemy_instance = enemy_rifle_scn.instance()
	elif enemy_type == "shotgun":
		enemy_instance = enemy_shotgun_scn.instance()
	elif enemy_type == "pistol":
		enemy_instance = enemy_pistol_scn.instance()
	else:
		enemy_instance = enemy_rifle_scn.instance()
	enemies.add_child(enemy_instance)
	
	enemy_instance.nav = self
	enemy_instance.world_state["has_target"] = has_target
	enemy_instance.replan_actions() # TODO: shouldn't this be at the end?
	enemy_instance.player = player
	enemy_instance.translation = get_closest_point(spawn_pos)
	#TODO: fix how enemies acquire patrol routes
	enemy_instance.patrolNodes = (patrol_route if patrol_route != null
		else $PatrolRoutes.get_child(0).get_children())


func _on_enemy_spawn_triggered(location: Vector3,
								enemy_type: String,
								patrol_route,
								has_target: bool) -> void:
	_spawn_enemy(location, enemy_type, patrol_route, has_target)


# TODO: This could possibly be improved by moving it into the player and
# 		having a front vision, flanking, and rear area that detect nodes
func _update_cover() -> void:
	var space_state = get_world().direct_space_state
	var h = player.hitboxes()[0]
	for n in get_tree().get_nodes_in_group("navnodes"):
		var body_ray = space_state.intersect_ray(
			h.global_transform.origin,
			n.global_transform.origin,
			[], # exclude
			0b00001, # collides with 0...0, 0, 0, 0, world
			true, # collide with bodies  
			false) # collide with areas
		if body_ray.empty():
			# This was empty because the navnode collision was disabled,
			# now, this path should not execute.
			n.mark_visible()
			continue
			
		var collider = body_ray.collider
		if collider == n:
			n.mark_visible()
			
		else:
			n.mark_not_visible()

func spawn_drone(spawn_pos: Vector3, owner: Node) -> void:
	var enemy_drone = drone.instance()
	enemies.add_child(enemy_drone)
	
	enemy_drone.nav = self
	enemy_drone.replan_actions()
	enemy_drone.player = player
	enemy_drone.translation = get_closest_point(Vector3(spawn_pos.x + 1, 0, spawn_pos.z + 1))
	enemy_drone.enemy_owner = weakref(owner)
	owner.drone = weakref(enemy_drone)

func _on_temporary_object_spawned(obj):
	temporary_nodes.add_child(obj)


