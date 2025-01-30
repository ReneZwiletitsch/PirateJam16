extends Node2D

@onready var level;

var max_floors: int = 5;
var current_floor: int = 0;

var start_room = preload("res://levels/room_start.tscn");
var boss_room = preload("res://levels/room_boss.tscn");
var level_scene = preload("res://levels/level.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var inst = start_room.instantiate()
	add_child(inst, true)
	level = inst

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("DEBUG_next_level"):
		next_floor()
	if event.is_action_pressed("DEBUG_prev_level"):
		prev_floor()

func new_floor():
	level.queue_free()
	var inst = level_scene.instantiate()
	inst.num_rooms = floor_rooms()
	add_child(inst, true)
	level = inst
	
	var rng = RandomNumberGenerator.new()
	var room_rand = rng.randi_range(1, floor_rooms() - 1)
	var stair_room = level.rooms[room_rand]
	var stair_node = get_node("Stairs");
	stair_node.position = stair_room.bounds.get_center()

func next_floor():
	if current_floor < max_floors:
		current_floor += 1;
	if current_floor == max_floors:
		level.queue_free()
		var inst = boss_room.instantiate()
		add_child(inst, true)
		level = inst
	else:
		new_floor()

func prev_floor():
	print(current_floor);
	if current_floor > 0:
		current_floor -= 1
		if current_floor == 0: # Return to base room case
			level.queue_free()
			var inst = start_room.instantiate()
			add_child(inst, true)
			level = inst
		else:
			new_floor()
	return

func floor_rooms() -> int:
	match current_floor:
		0:
			return 5
		1:
			return 7
		3:
			return 9
		4:
			return 11
		5:
			return 6
		_:
			return 9
