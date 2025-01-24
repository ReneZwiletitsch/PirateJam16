extends Node2D

@onready var all_ai_char_instances :=[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#temp, add navigation region as well when generating the level
	
	var alive_counter := 3
	var dead_counter := 2
	for i in range(alive_counter):
		spawn_ai_char(false)
		
	for i in range(dead_counter):
		spawn_ai_char(true)
	
		
		
		
func _input(event):
	if event.is_action_pressed("necromancy"):
		for i in all_ai_char_instances:
			i.necromancy()
			if i.playercontrol:
				Singleton.current_character = i

	#player attacking
	elif event.is_action_pressed("attack"):
		if Singleton.current_character != null:
			#print(Singleton.current_character.get_local_mouse_position().angle())

			if Singleton.current_character.attack_rdy:
				Singleton.current_character.attack() #starts cooldown
				
				for i in all_ai_char_instances:
					#check if in cone
					var mouse_vec = Singleton.current_character.get_local_mouse_position().normalized()
					
					var enemy_pos = (i.global_position-Singleton.current_character.global_position)
					var enemy_vec = enemy_pos.normalized()
					if abs(acos(mouse_vec.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< Singleton.basic_character_range:
						print("is attacked")
						i.character_damage()
					else:
						print("dodged")
				print("#########")
					
			else: 
				print("on cooldown",Singleton.max_attack_cooldown/Singleton.current_player_dex)
		else:
			print("no character")
			
			
	elif event.is_action_pressed("test"):
		pass






func spawn_ai_char(dead):
	print("spawning")
	var rng = RandomNumberGenerator.new()
	var scene = preload("res://Scenes/AIChar.tscn")
	var x_rand = rng.randf_range(-100, 100)
	var y_rand = rng.randf_range(-100, 100)
	
	var instance = scene.instantiate()
	instance.position = Vector2(x_rand,y_rand)
	add_child(instance,true)
	all_ai_char_instances.append(instance)
	instance.dead = dead
	
	
	
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
