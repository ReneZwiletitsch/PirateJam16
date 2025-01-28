extends Node2D
@onready var necromancer_instance = null
@onready var boss_instance = null
@onready var second_phase_triggered = false


func _input(event):
	if event.is_action_pressed("attack"):

		#print(Singleton.current_character.get_local_mouse_position().angle())
		if second_phase_triggered:
			if necromancer_instance.attack_rdy:
				necromancer_instance.attack() #starts cooldown
				
			else: 
				print("on cooldown",Singleton.max_attack_cooldown/necromancer_instance.current_char.dex)












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
		
		
		
		
	#initialize scene
	Singleton.player_died = false
	spawn_boss()		
	#zoomed in at necromancer dead
	spawn_necromancer()
	await get_tree().create_timer(3).timeout 


	
	
	#necromancer stands up
	necromancer_instance.dead = false
	
	
	#zoom out, bbeg becomes visible
	
	#necromancer summons characters and fight starts
		
		
		
		
	var ai_counter :=0
	Singleton.player_position = Vector2(0,300)
	for i in Singleton.all_ai_char_instances:
		if i.dead and not i.fully_dead:
			i.boss_fight = true
			i.necromancy()
			i.position = Vector2 (ai_counter%5*30,ai_counter/5 *30)
			ai_counter += 1
			print(ai_counter)



func spawn_boss():
	print("spawning boss")
	var scene = preload("res://Scenes/AIChar.tscn")
	var x = 0
	var y = -100
	
	var instance = scene.instantiate()
	instance.position = Vector2(x,y)
	add_child(instance,true)
	instance.load_attributes(instance.character.boss)
	instance.current_char.strenght = 30
	instance.current_char.dex = 10
	instance.player_attack_woundup.connect(player_attack)
	boss_instance = instance
	Singleton.current_character=instance
	Singleton.current_player_strenght = instance.current_char.strenght


func spawn_necromancer():
	print("spawning necromancer")
	var scene = preload("res://Scenes/AIChar.tscn")
	var x = -100
	var y = 100
	
	var instance = scene.instantiate()
	instance.position = Vector2(x,y)
	add_child(instance,true)
	instance.load_attributes(instance.character.necromancer)
	instance.current_char.strenght = 100
	instance.current_char.dex = 30
	instance.current_char.willpower = 1
	instance.current_char.max_hp = 1000
	instance.player_attack_woundup.connect(player_attack)
	necromancer_instance = instance



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
	
	if dead:
		instance.load_attributes(instance.character.dead)
	else:
		instance.load_attributes(instance.character.alive)


#used by boss
func player_attack(mouse_vec,boss):
	for i in Singleton.all_ai_char_instances:
		#check if in cone	
		var enemy_pos = (i.global_position-Singleton.current_character.global_position)
		var enemy_vec = enemy_pos.normalized()
		if abs(acos(mouse_vec.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< Singleton.basic_character_range:
			i.character_damage()
			
	var enemy_pos 
	if boss:
		enemy_pos = (necromancer_instance.global_position-boss_instance.global_position)
	else:
		enemy_pos = (boss_instance.global_position-necromancer_instance.global_position)
	
	var enemy_vec = enemy_pos.normalized()
	if abs(acos(mouse_vec.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< Singleton.basic_character_range:
		if boss:
			Singleton.player_damage(boss_instance.current_char.strenght)
		else:
			Singleton.boss_damage(necromancer_instance.current_char.strenght)

	


func second_phase():
	print("all ai dead, starting second phase")
	necromancer_instance.playercontrol = true
	necromancer_instance.current_char.willpower = 0
	Singleton.current_player_hp = necromancer_instance.current_char.max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Singleton.boss_defeated:
		print("YOU WON")
	if Singleton.player_died:
		print("YOU LOST")

	if not second_phase_triggered:
		var in_phase_one := false
		for i in Singleton.all_ai_char_instances:
			if not i.fully_dead:
				in_phase_one = true			
		if not in_phase_one:
			second_phase()
			second_phase_triggered = true
		
