extends Node2D

@onready var level;

var max_floors: int = 4;
var current_floor: int = 0;

var start_room = preload("res://levels/room_start.tscn");
var boss_room = preload("res://Scenes/BossFight.tscn");
var level_scene = preload("res://levels/level.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var inst = start_room.instantiate()
	add_child(inst, true)
	level = inst
	DialogueManager.start_dialogue(self, Singleton.intro_story_and_tutorial)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("DEBUG_next_level"):
		next_floor()
	if event.is_action_pressed("DEBUG_prev_level"):
		prev_floor()
	if event.is_action_pressed("DEBUG_to_boss_room"):
		level.queue_free()
		var inst = boss_room.instantiate()
		add_child(inst, true)
		level = inst
		var stair_node = get_node("Stairs")
		stair_node.queue_free()

func new_floor():
	save_characters()
	level.queue_free()
	var inst = level_scene.instantiate()
	inst.num_rooms = floor_rooms()
	add_child(inst, true)
	level = inst
	
	var rng = RandomNumberGenerator.new()
	var room_rand = rng.randi_range(1, floor_rooms() - 1)
	var stair_room = level.rooms[room_rand]
	var stair_node = get_node("Stairs")
	stair_node.position = stair_room.bounds.get_center() * 16

func next_floor():
	if current_floor < max_floors:
		current_floor += 1;
	if current_floor == max_floors:
		DialogueManager.fuck_this_shit()
		level.queue_free()
		Singleton.current_character = null
		$"../Camera2D".queue_free()
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

func save_characters():
	for i in Singleton.all_ai_char_instances:
		if i.dead and not i.fully_dead:
			Singleton.chars_for_boss_fight.append([i.current_char.strenght,i.current_char.speed,i.current_char.dex,i.current_char.willpower,i.current_char.curr_hp])
	Singleton.all_ai_char_instances = []
	Singleton.curr_char_stats = [Singleton.current_character.current_char.strenght,Singleton.current_character.current_char.speed,Singleton.current_character.current_char.dex,Singleton.current_character.current_char.willpower,Singleton.current_character.current_char.curr_hp]
	print("stats: ",Singleton.curr_char_stats)

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
