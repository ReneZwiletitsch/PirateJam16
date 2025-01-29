extends Node2D

const room_size: Vector2i = Vector2i(18, 10);

const atlas_wall_tl = Vector2i(0, 0);
const atlas_wall_tr = Vector2i(7, 0);
const atlas_wall_br = Vector2i(7, 7);
const atlas_wall_bl = Vector2i(0, 7);

const atlas_wall_t = Vector2i(1, 0);
const atlas_wall_b = Vector2i(1, 7);
const atlas_wall_l = Vector2i(0, 1);
const atlas_wall_r = Vector2i(7, 1);

const atlas_floor = Vector2i(1, 1);

var num_rooms: int = 5;

@onready var rooms :=[]

var num_enemies: int = 1;
var num_dead_bodies: int = 2;





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_rooms()
	draw_rooms()
	for i in Singleton.all_ai_char_instances:
		i.player_attack_woundup.connect(player_attack)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Singleton.current_character == null:
		if not Singleton.staff_instance:
			#spawn staff
			var scene = preload("res://Scenes/staff.tscn")
			var instance = scene.instantiate()
			instance.rotate(PI/2)
			instance.set_scale(Vector2(0.7,0.7))
			instance.position = Singleton.player_position
			add_child(instance,true)
			Singleton.staff_instance = instance
						
		var alive_check = false
		for i in Singleton.all_ai_char_instances:
			if (i.global_position - Singleton.player_position).length()< Singleton.necromancy_range and i.dead and not i.fully_dead:
				alive_check = true
		if not alive_check:
			Singleton.game_lost = true
			print("YOU DIED")
				

func _input(event):
	if event.is_action_pressed("necromancy"):
		for i in Singleton.all_ai_char_instances:
			i.necromancy()
			if i.playercontrol:
				Singleton.current_character = i
				#despawn the staff
				remove_child(Singleton.staff_instance)
				Singleton.staff_instance = null
				

	#player attacking
	elif event.is_action_pressed("attack"):
		if Singleton.current_character != null:
			#print(Singleton.current_character.get_local_mouse_position().angle())

			if Singleton.current_character.attack_rdy:
				Singleton.current_character.attack() #starts cooldown
				
			else: 
				print("on cooldown",Singleton.max_attack_cooldown/Singleton.current_player_dex)
		else:
			print("no character")
			




func player_attack(mouse_vec,boss):
	for i in Singleton.all_ai_char_instances:
		if i.character_index != i.attribute_list[i.character.undead][i.attribute.character_index]:
			#check if in cone	
			var enemy_pos = (i.global_position-Singleton.current_character.global_position)
			var enemy_vec = enemy_pos.normalized()
			if abs(acos(mouse_vec.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< Singleton.basic_character_range:
				i.character_damage()
				







func generate_rooms():
	var room_graph = generate_room_graph();
	for tile in room_graph.graph.keys():
		var doors = room_graph.graph[tile];
		rooms.append(tiled_room_from_graph(tile, doors));
	print("Generated ", len(rooms), " rooms")

func generate_room_graph() -> RoomGraph:
	var room_graph: RoomGraph = RoomGraph.new();
	room_graph.add_node(Vector2i(0, 0)); # base room
	while len(room_graph.graph) < num_rooms:
		var rooms_len = len(room_graph.graph)
		var rand_room = room_graph.graph.keys();
		# Get target room
		var seed_room = rand_room[randi_range(0, rooms_len-1)]
		var new_room_dir = randi_range(0, 3);
		var new_room;
		match new_room_dir:
			0: #up
				new_room = seed_room + Vector2i(0, 1);
			1: #right
				new_room = seed_room + Vector2i(1, 0);
			2: #down
				new_room = seed_room + Vector2i(0, -1);
			3: #left
				new_room = seed_room + Vector2i(-1, 0);

		# Retry if not valid room target
		if room_graph.graph.keys().has(new_room):
			continue
		room_graph.add_node(new_room)
	room_graph.gen_connectivity_map();
	print("Room graph generated...")
	return room_graph

func draw_rooms():
	for room in rooms:
		room.draw()

func validate_rooms():
	# Ensure any room with a door has a partner room with a door on the other side.
	pass

func build_doors():
	pass

enum TransitionDir {
	Up = 1,
	Down = 2,
	Left = 3,
	Right = 4
}

func tiled_room_from_graph(grid_pos: Vector2i, doors: Array[TransitionDir]):
	var start = grid_pos * (room_size + Vector2i(1, 1));
	var bounds = Rect2i(start, room_size);
	var doors_pos: Array[Vector2i] = []
	# This is really fucky and I don't know why it works like this, it feels like u/d l/r should be inverted
	for door: TransitionDir in doors:
		match door:
			TransitionDir.Up:
				var pos = start + Vector2i(bounds.size.x/2, bounds.size.y)
				doors_pos.append(pos);
			TransitionDir.Right:
				var pos = start + Vector2i(bounds.size.x, bounds.size.y/2)
				doors_pos.append(pos);
			TransitionDir.Down:
				var pos = start + Vector2i(bounds.size.x/2, 0)
				doors_pos.append(pos);
			TransitionDir.Left:
				var pos = start + Vector2i(0, bounds.size.y/2)
				doors_pos.append(pos);
	var room_scene = preload("res://levels/room.tscn");
	var inst = room_scene.instantiate();
	inst.bounds = bounds
	inst.doors = doors_pos
	add_child(inst, true)
	
	
	for i in range(num_enemies):
		inst.spawn_enemy(false)
	for i in range(num_dead_bodies):
		inst.spawn_enemy(true)
	
	return inst










# Data type for a undirected graph of rooms in a grid, where each room is a 1x1 item in a grid.
class RoomGraph:
	var graph: Dictionary = {}
	
	func add_node(pos: Vector2i):
		graph[pos] = []
	
	func get_neighbors(query_room: Vector2i):
		var neighbors = [];
		# cardinal dirs
		for pos in [
			Vector2i(1, 0), 
			Vector2i(-1, 0), 
			Vector2i(0, 1), 
			Vector2i(0, -1)
			]:
				var neigh_pos = query_room + pos
				if graph.has(neigh_pos):
					neighbors.append(neigh_pos)
		return neighbors
	
	func get_neighbor_dir(query: Vector2i, neighbor: Vector2i):
		var diff = query - neighbor;
		if diff.x != 0 && diff.y !=0:
			print("At least one neighbor value should be zero. What happened?")
		var dir: TransitionDir;
				
		if diff.x > 0:
			dir = TransitionDir.Left
		elif diff.x < 0:
			dir = TransitionDir.Right
		elif diff.y > 0:
			dir = TransitionDir.Down
		elif diff.y < 0:
			dir = TransitionDir.Up
		return dir
	
	func gen_connectivity_map():
		for node: Vector2i in graph.keys():
			var transition_dirs: Array[TransitionDir]
			var neighbors = get_neighbors(node);
			for neighbor in neighbors:
				transition_dirs.append(get_neighbor_dir(node, neighbor));
			graph[node] = transition_dirs
			
	func iter():
		return 
