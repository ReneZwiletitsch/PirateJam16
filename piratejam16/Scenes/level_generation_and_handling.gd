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
			
			
	elif event.is_action_pressed("test"):
		pass



func player_attack(mouse_vec):
	for i in all_ai_char_instances:
		#check if in cone	
		var enemy_pos = (i.global_position-Singleton.current_character.global_position)
		var enemy_vec = enemy_pos.normalized()
		if abs(acos(mouse_vec.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< Singleton.basic_character_range:
			i.character_damage()



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
	instance.player_attack_woundup.connect(player_attack)
	if dead:
		instance.find_child("AnimatedSprite2D").set_animation("dead")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Singleton.current_character == null:
		if not Singleton.staff_instance:
			#spawn staff
			var scene = preload("res://Scenes/staff.tscn")
			var instance = scene.instantiate()
			instance.position = Singleton.player_position
			add_child(instance,true)
			Singleton.staff_instance = instance
						
		var alive_check = false
		for i in all_ai_char_instances:
			if (i.global_position - Singleton.player_position).length()< Singleton.necromancy_range and i.dead and not i.fully_dead:
				alive_check = true
		if not alive_check:
			Singleton.game_lost = true
			print("YOU DIED")
				
			
			
