extends Node2D
@onready var necromancer_instance = null
@onready var boss_instance = null
@onready var second_phase_triggered = false
@onready var all_ai_char_instances = []

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
	
	#temp, just for debugging
	Singleton.chars_for_boss_fight = [[2, 81, 98, 0.14359773695469, 76], [5, 66, 75, 0.10738767683506, 10], [3, 64, 2, 0.12045760452747, 35], [2, 56, 71, 0.0115536917001, 59], [1, 91, 83, 0.07365279644728, 45], [7, 86, 35, 0.07376900315285, 93], [5, 61, 2, 0.11817486584187, 54], [10, 67, 13, 0.02707774750888, 72], [7, 95, 88, 0.09477481991053, 35], [8, 76, 7, 0.07149560004473, 26]]

	for i in Singleton.chars_for_boss_fight:
		var curr_instance 
		curr_instance = spawn_ai_char(true,false)
		curr_instance.current_char.strenght = i[0]
		curr_instance.current_char.speed = i[1]
		curr_instance.current_char.dex = i[2]
		curr_instance.current_char.willpower = i[3]
		curr_instance.current_char.curr_hp = i[4]
		
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
	for i in all_ai_char_instances:
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
	all_ai_char_instances.append(instance)
	
	if dead:
		instance.load_attributes(instance.character.dead)
	else:
		instance.load_attributes(instance.character.alive)
	return instance

#used by boss, and player
func player_attack(mouse_vec,boss):
	for i in all_ai_char_instances:
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
		var scene = preload("res://Scenes/damage_indicator.tscn")
		var instance = scene.instantiate()
		add_child(instance,true)
		if boss:
			Singleton.player_damage(boss_instance.current_char.strenght)
			instance.label.text = str(boss_instance.current_char.strenght)
			instance.label.set("theme_override_colors/font_color", Color.YELLOW)
			instance.global_position = necromancer_instance.global_position
		else:
			Singleton.boss_damage(necromancer_instance.current_char.strenght)
			instance.label.text = str(necromancer_instance.current_char.strenght)
			instance.label.set("theme_override_colors/font_color", Color(1, 0, 1, 1))
			instance.global_position = boss_instance.global_position

	


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
		for i in all_ai_char_instances:
			if not i.fully_dead:
				in_phase_one = true			
		if not in_phase_one:
			second_phase()
			second_phase_triggered = true
		
