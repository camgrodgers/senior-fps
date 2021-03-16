extends KinematicBody
class_name Enemy

onready var signals: Signals = get_node("/root/Signals")

var ENEMY_SPEED: int = 6
var ENEMY_RANGE: float = 60.0
var MAX_HP: float = 2.0
var DAMAGE_MULTIPLIER: float = 1.0

var nav: Navigation = null
var player = null
export var patrolNodes: Array = []
export var coverNodes: Array = []
var path: Array = []

export var patrolNodeIndex = 1
var currentNode = null

# Relations to player
var player_distance: float = 0.0
var player_danger: float = 0.0
# TODO: is it possible to move this up the tree somehow?
var last_player_position: Vector3 = Vector3(-1000, -1000, -1000)

var world_state: Dictionary = {
	"can_see_player" : false, 
	"in_cover" : false,
	"has_target" : false,
	"patrolling" : true,
	"in_range" : false,
	"in_danger" : false,
}

var action_plan: Array
var action_index: int = 0

##IDLE, MOVETO, TAKEACTION BELONG TO GOAP Logic
enum {
	IDLE,
	MOVE_TO,
	TAKE_ACTION
}

var state = IDLE


func _ready():
	rng.randomize()
	cover_timer_limit = rng.randf_range(1, 10)
	$PatrolTimer.set_paused(true)

# Updates the path variable to lead to a new destination
func update_path(goal: Vector3) -> void:
	var new_path_pool: PoolVector3Array = nav.get_simple_path(translation, nav.get_closest_point(goal), true)
	var new_path: Array = Array(new_path_pool)
	if new_path == null or new_path.empty():
		print("got null path")
		return
	path = new_path

# Moves the enemy along the path held in 'path'
func move_along_path(delta: float, lookat: bool = false) -> void:
	if path == null or path.empty():
		print("null or empty path")
		return
	
	var moving = ENEMY_SPEED * delta
	var to = path[0]
	while translation.distance_to(to) < moving:
		path.pop_front()
		if path.empty():
			return
		to = path[0]
	
	var velocity = translation.direction_to(path[0]).normalized() * ENEMY_SPEED
	if lookat:
		look_at(global_transform.origin + velocity, Vector3.UP)
#	translation = translation.linear_interpolate(to, moving / distance)
	move_and_slide(velocity, Vector3.UP)

# Find the nearest node to take cover at
func get_shortest_node():
	var shortestNodePathDistance = INF
	var shortestNodePathIndex = null
	var currentNodePathIndex = 0
	for n in coverNodes:
		if n.occupied == true:
			currentNodePathIndex += 1
			continue
		var path_to_node = nav.get_simple_path(translation, n.translation, true)
		var total_distance = get_path_distance(path_to_node)
		if total_distance < shortestNodePathDistance:
			shortestNodePathIndex = currentNodePathIndex
			shortestNodePathDistance = total_distance
		currentNodePathIndex += 1
	if shortestNodePathIndex == null:
		print("no free nodes")
		return currentNode
	return coverNodes[shortestNodePathIndex]

func prep_node(node):
	if currentNode != node:
		clear_node_data()
	update_path(node.translation)
	currentNode = node
	currentNode.occupied = true
	currentNode.occupied_by = self

# Check if player is visible inside the enemy's vision cone
func check_vision() -> bool:
	var collisions = $VisionCone.get_overlapping_areas()
	if collisions.empty():
		world_state["can_see_player"] = false
		return false
	

	world_state["can_see_player"] = cast_to_player_hitboxes()
	if not world_state["has_target"]:
		world_state["has_target"] = world_state["can_see_player"]

	return world_state["can_see_player"]


# If it returns true, a raycast can hit the player's hitboxes
func cast_to_player_hitboxes() -> bool:
	var space_state = get_world().direct_space_state
	for h in player.hitboxes():
		var body_ray = space_state.intersect_ray(
			$Gun.global_transform.origin,
			h.global_transform.origin,
			[self], # exclude
			0b1011, # collides with 0...hiding, 0, player, world
			true, # collide with bodies  
			true) # collide with areas
		if body_ray.empty():
			print("empty ray")
			# TODO: why does this keep printing?
			continue
		
		var collider = body_ray.collider
#		print(collider)
		if collider == player:
			return true
			
	return false

# If can see player, turn to look at the player
func aim_at_player(_delta):
	world_state["can_see_player"] = cast_to_player_hitboxes()
	if not world_state["can_see_player"]: return
	player_distance = player.translation.distance_to(translation)
	last_player_position = player.translation
	# TODO: Could be changed to work in an area radius
	get_tree().call_group("enemies", "update_last_player_position", last_player_position)
#	target_speed = target.vel.abs().length()
	
	look_at(player.translation, Vector3(0,1,0))
	rotation_degrees.x = 0

var _shoot_timer: float = 0
var _shoot_interval: float = 2

func shoot_around_player(delta):
	rng.randomize()
	_shoot_timer += delta
	if _shoot_timer < _shoot_interval:
		return
	_shoot_timer = 0 - rng.randf_range(0, 2)
	$Enemy_audio_player.play_sound($Enemy_audio_player.enemy_shot)

	if not world_state["can_see_player"]: return
	var tracer: Tracer = Tracer.new()
	signals.emit_signal("temporary_object_spawned", tracer)
	var from = $Gun.global_transform.origin
	var to_vec = from.direction_to(player.global_transform.origin) * (player_distance * 2)
	rng.randomize()
	var offset_rotation: Vector3 = Vector3(
			rng.randf_range(-100, 100),
			rng.randf_range(-100, 100),
			rng.randf_range(-100, 100))
	offset_rotation = offset_rotation.normalized()
	to_vec = to_vec.rotated(Vector3(0, 0, 1),
			deg2rad(10 / (player_distance / 10) * offset_rotation.z))
	to_vec = to_vec.rotated(Vector3(1, 0, 0),
			deg2rad(10 / (player_distance / 10) * offset_rotation.x))
	var to = from + to_vec.rotated(Vector3(0, 1, 0),
			deg2rad(10 / (player_distance / 10) * offset_rotation.y))
	tracer.set_coordinates(from, to)


var rng = RandomNumberGenerator.new()
var cover_timer = 0
var cover_timer_limit = 3

func check_goal() -> bool:
	return $GOAP_Planner.check_current_goal(world_state)

func replan_actions():
	state = IDLE
	check_range()
	check_vision()
	check_cover()

func ready_for_action():
	state = TAKE_ACTION

func go_to_next_action():
	action_index = action_index + 1
	state = MOVE_TO
	if action_index > action_plan.size() - 1:
		action_index = 0
		state = IDLE

func _process(delta):
	
	if player != null and player.is_dead:
		return
	
	if state != IDLE and not check_goal():
		state = IDLE
		action_index = 0
		rng.randomize()
		#ReplanTimer currently does nothing
		#Functionality in place to possibly replan actions at semi-random time intervals
#		$ReplanTimer.set_wait_time(rng.randf_range(3.5, 5.0))
#		$ReplanTimer.start()
	
	match state:
		IDLE:
			action_plan = $GOAP_Planner.plan_actions(world_state)
			action_index = 0
			state = MOVE_TO
		MOVE_TO:
			action_plan[action_index].move_to(self, delta)
		TAKE_ACTION:
			action_plan[action_index].take_action(self, delta)
	
	return

func check_cover():
	if currentNode == null or translation.distance_to(currentNode.translation) > 1:
		world_state["in_cover"] = false
		

func check_range():
	if player == null:
		world_state["in_range"] = false
	else:
		world_state["in_range"] = translation.distance_to(player.translation) < ENEMY_RANGE
	return world_state["in_range"]

# Length of path to a point
func get_path_distance_to(goal: Vector3) -> float:
	# TODO: What if this is null?
	var temp_path_pool: PoolVector3Array = nav.get_simple_path(translation, goal, true)
	var temp_path: Array = Array(temp_path_pool)
	return get_path_distance(temp_path)

# Length of a path
func get_path_distance(path_array: Array) -> float:
	var total_distance: float = translation.distance_to(path_array[0])
	for i in range(path_array.size() - 2):
		total_distance += path_array[i].distance_to(path_array[i + 1])
	return total_distance

func clear_node_data() -> void:
	path.clear()
	world_state["in_cover"] = false
	if currentNode != null:
		currentNode.occupied = false
		currentNode.occupied_by = null

# Respond to player attacks
var HP: float = 0.0


func take_damage(damage: float) -> void:
	world_state["has_target"] = true

	alert_comrades()
	$CSGCombiner.get_node("CSGCylinder" + str(int(HP))).visible = false
	HP += damage
	world_state["in_danger"] = HP / MAX_HP >= 0.5
	
	if HP < MAX_HP:
		$CSGCombiner.get_node("CSGCylinder" + str(int(HP))).visible = true
		replan_actions()
		return
	var corpse_scn: Resource = preload("res://Enemies/DeadEnemy.tscn")
	var corpse = corpse_scn.instance()
	corpse.transform = self.transform
	var weapon_drop_scn: Resource = preload("res://Equippables/AK47ItemDrop.tscn")
	var weapon_drop = weapon_drop_scn.instance()
	weapon_drop.transform = self.transform
	weapon_drop.translation.y += 2
	
	signals.emit_signal("temporary_object_spawned", corpse)
	signals.emit_signal("temporary_object_spawned", weapon_drop)
	clear_node_data()
	self.queue_free()

func alert_comrades() -> void:
	# TODO: Replace this with something that's restricted to a certain area, and/or a signal?
	get_tree().call_group("enemies", "alert_to_player")
	
func alert_to_player() -> void:
	world_state["has_target"] = true
	world_state["patrolling"] = false

func update_last_player_position(position: Vector3) -> void:
	last_player_position = position
