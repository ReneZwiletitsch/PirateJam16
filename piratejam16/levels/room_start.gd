extends TileMapLayer

var enemy = preload("res://Scenes/AIChar.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_enemy(true)
	spawn_enemy(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Singleton.current_character == null:
		if not Singleton.staff_instance:
			#spawn staff
			var scene = preload("res://Scenes/staff.tscn")
			var instance = scene.instantiate()
			instance.rotate(PI/2)
			instance.set_scale(Vector2(0.7,0.7))
			instance.position = Singleton.player_position #+ Vector2(10,35)
			print(Singleton.player_position)
			add_child(instance,true)
			Singleton.staff_instance = instance
						
		var alive_check = false
		for i in Singleton.all_ai_char_instances:
			if (i.global_position - Singleton.player_position).length() < Singleton.necromancy_range and i.dead and not i.fully_dead:
				alive_check = true
		if not alive_check:
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

func spawn_enemy(dead):
	var instance = enemy.instantiate()
	var rng = RandomNumberGenerator.new()
	var y_rand = 130
	var x_rand = rng.randi_range(40, 250)

	print("spawning:",x_rand," ",y_rand)
	instance.position = Vector2(x_rand, y_rand);
	add_child(instance,true)
	Singleton.all_ai_char_instances.append(instance)

	if dead:
		instance.load_attributes(instance.character.dead)
	else:
		instance.load_attributes(instance.character.alive)
	return instance
