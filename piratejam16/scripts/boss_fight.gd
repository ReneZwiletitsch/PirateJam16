extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#temp, debugging start ################
	
	var alive_counter := 0
	var dead_counter := 11
	var fully_dead_counter := 2
	
	for i in range(alive_counter):
		spawn_ai_char(false,false)
		
	for i in range(dead_counter):
		spawn_ai_char(true,false)
		
	for i in range(fully_dead_counter):
		spawn_ai_char(true,true)
	#temp, debugging over ########################
		
		
		
	var ai_counter :=0
	Singleton.player_position = Vector2(0,300)
	for i in Singleton.all_ai_char_instances:
		if i.dead and not i.fully_dead:
			i.boss_fight = true
			i.necromancy()
			i.position = Vector2 (ai_counter%5*30,ai_counter/5 *30)
			ai_counter += 1
			print(ai_counter)
			
	#spawn_boss()		
	Singleton.current_character=$BBEG



func spawn_boss():
	print("spawning boss")
	var scene = preload("res://Scenes/AIChar.tscn")
	var x = 0
	var y = -100
	#temp, change when boss is implemented into ai scipt
	var dead =false
	var fully_dead = false
	
	var instance = scene.instantiate()
	instance.position = Vector2(x,y)
	add_child(instance,true)
	Singleton.current_character=instance
	instance.dead = dead
	instance.fully_dead = fully_dead
	instance.find_child("AnimatedSprite2D").set_animation("deadge")



#temp, delete for full implementation
func spawn_ai_char(dead,fully_dead):
	print("spawning")
	var rng = RandomNumberGenerator.new()
	var scene = preload("res://Scenes/AIChar.tscn")
	var x_rand = rng.randf_range(-100, 100)
	var y_rand = rng.randf_range(-100, 100)
	
	var instance = scene.instantiate()
	instance.position = Vector2(x_rand,y_rand)
	add_child(instance,true)
	Singleton.all_ai_char_instances.append(instance)
	instance.dead = dead
	instance.fully_dead = fully_dead

	if dead:
		instance.find_child("AnimatedSprite2D").set_animation("dead")
		
	if fully_dead:
		instance.find_child("AnimatedSprite2D").set_animation("deadge")





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Singleton.boss_defeated:
		print("YOU WON")
