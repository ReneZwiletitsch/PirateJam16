extends TileMapLayer

class_name ProceduralLevel

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

var level_rooms: Array[TiledRoom];

var num_rooms: int = 10;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_rooms()
	draw_rooms()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func generate_rooms():
	var rooms: Array[TiledRoom] = []
	var room_graph = generate_room_graph();
	for tile in room_graph.graph.keys():
		var doors = room_graph.graph[tile];
		rooms.append(tiled_room_from_graph(tile, doors));
	level_rooms = rooms

func generate_room_graph() -> RoomGraph:
	var room_graph: RoomGraph = RoomGraph.new();
	room_graph.add_node(Vector2i(0, 0)); # base room
	while len(room_graph.graph) < num_rooms:
		var rooms_len = len(room_graph.graph)
		print("Rooms left:", num_rooms - rooms_len);
		print("Rooms generated:", rooms_len)
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
	return room_graph
	
func is_in_room(room: TiledRoom, point: Vector2i) -> bool:
	return room.bounds.has_point(point)

func draw_rooms():
	for room in level_rooms:
		draw_room(room)

func draw_room(room: TiledRoom):

	# base floor
	for x in range(room.bounds.position.x, room.bounds.end.x + 1):
		for y in range(room.bounds.position.y, room.bounds.end.y + 1):
			var pos = Vector2i(x, y)
			if x == room.bounds.position.x:
				set_cell(pos, 2, atlas_wall_l)
			elif x == room.bounds.end.x:
				set_cell(pos, 2, atlas_wall_r)
			elif y == room.bounds.position.y:
				set_cell(pos, 2, atlas_wall_t)
			elif y == room.bounds.end.y:
				set_cell(pos, 2, atlas_wall_b)
			else:
				set_cell(pos, 2, atlas_floor)
	
	# Corners
	var top_l = room.bounds.position
	var top_r = Vector2i(room.bounds.end.x, room.bounds.position.y)
	var bot_r = room.bounds.end
	var bot_l = Vector2i(room.bounds.position.x, room.bounds.end.y)
	
	set_cell(top_l, 2, atlas_wall_tl)
	set_cell(top_r, 2, atlas_wall_tr)
	set_cell(bot_r, 2, atlas_wall_br)
	set_cell(bot_l, 2, atlas_wall_bl)
	
	# Doors
	for door in room.doors:
		set_cell(door, 2, atlas_floor)

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
	var room = TiledRoom.new(bounds)
	room.doors = doors_pos
	return room

class TiledRoom:
	var bounds: Rect2i
	var doors: Array[Vector2i]
	
	# @position - The x,y coordinate of the top right corner of the room.
	# @size - the size of the room, beginning from the top right corer, in x,y terms
	func _init(rect: Rect2i):
		bounds = rect
	
	func is_corner(point: Vector2i) -> bool:
		return corners().any(func(x, y): return(x == y))
		
	func corners() -> Array:
		return [
			Vector2i(bounds.position.x, bounds.position.y), 
			Vector2i(bounds.end.x, bounds.position.y), 
			Vector2i(bounds.end.x, bounds.end.y), 
			Vector2i(bounds.position.x, bounds.end.y)
			]
		

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
