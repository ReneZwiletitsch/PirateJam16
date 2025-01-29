extends TileMapLayer

const atlas_wall_tl = Vector2i(0, 0);
const atlas_wall_tr = Vector2i(7, 0);
const atlas_wall_br = Vector2i(7, 7);
const atlas_wall_bl = Vector2i(0, 7);

const atlas_wall_t = Vector2i(1, 0);
const atlas_wall_b = Vector2i(1, 7);
const atlas_wall_l = Vector2i(0, 1);
const atlas_wall_r = Vector2i(7, 1);

const atlas_floor = Vector2i(1, 1);

var bounds: Rect2i
var doors: Array[Vector2i]

var num_enemies: int = 2;
var enemy = preload("res://Scenes/AIChar.tscn")

@onready var enemies :=[]

# @position - The x,y coordinate of the top right corner of the room.
# @size - the size of the room, beginning from the top right corer, in x,y terms
func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func is_corner(point: Vector2i) -> bool:
	return corners().any(func(x, y): return(x == y))
	
func corners() -> Array:
	return [
		Vector2i(bounds.position.x, bounds.position.y), 
		Vector2i(bounds.end.x, bounds.position.y), 
		Vector2i(bounds.end.x, bounds.end.y), 
		Vector2i(bounds.position.x, bounds.end.y)
		]

func draw():
	print("Drawing...")
	# base floor
	for x in range(bounds.position.x, bounds.end.x + 1):
		for y in range(bounds.position.y, bounds.end.y + 1):
			var pos = Vector2i(x, y)
			if x == bounds.position.x:
				set_cell(pos, 2, atlas_wall_l)
			elif x == bounds.end.x:
				set_cell(pos, 2, atlas_wall_r)
			elif y == bounds.position.y:
				set_cell(pos, 2, atlas_wall_t)
			elif y == bounds.end.y:
				set_cell(pos, 2, atlas_wall_b)
			else:
				set_cell(pos, 2, atlas_floor)
	
	# Corners
	var top_l = bounds.position
	var top_r = Vector2i(bounds.end.x, bounds.position.y)
	var bot_r = bounds.end
	var bot_l = Vector2i(bounds.position.x, bounds.end.y)
	
	set_cell(top_l, 2, atlas_wall_tl)
	set_cell(top_r, 2, atlas_wall_tr)
	set_cell(bot_r, 2, atlas_wall_br)
	set_cell(bot_l, 2, atlas_wall_bl)
	
	# Doors
	for door in doors:
		set_cell(door, 2, atlas_floor)
	
	for i in range(num_enemies):
		spawn_enemy(false)

func spawn_enemy(dead):
	print("spawning")
	print("Bounds: ", bounds.position, bounds.end)
	var rng = RandomNumberGenerator.new()
	var x_rand = rng.randf_range(bounds.position.x+1, bounds.end.x-1)
	var y_rand = rng.randf_range(bounds.position.y+1, bounds.end.y-1)
	
	print(x_rand,"|", y_rand);
	
	var instance = enemy.instantiate()
	instance.position = Vector2(x_rand,y_rand) * 16;
	add_child(instance,true)
	enemies.append(instance)
	instance.dead = dead
	
# Designed to be called on node teardown, appends a list of valid summonable enemies
# for the boss battle
#func later_summonable_enemies():
#	for enemy in enemies:
#		if enemy.dead && !enemy.is_fully_dead:
#			singleton.boss_summon_enemies.append(enemy.current_char)
#	pass

# func stop_enemies():
# 	for enemies in enemy:
# 		enemy.stop()
# 
# func start_enemies():
# 	for enemies in enemy:
# 		enemy.start()
