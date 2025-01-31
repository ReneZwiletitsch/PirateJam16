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
	#camera zooms into necromancer
	var x = -100
	var y = 100
	var camera_start = Vector2(x, y);
	$Camera2D.set_position(camera_start)
	$Camera2D.zoom = Vector2(5,5)
	
	Singleton.aggro_range = 9999999
	#temp, just for debugging
	#Singleton.chars_for_boss_fight = [[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],[2, 81, 98, 0.14359773695469, 76],]

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
	await get_tree().create_timer(2).timeout
	necromancer_instance.dead = false
	#necromancer stands up
	print("TEMP necromancer revived")
	
	await get_tree().create_timer(2).timeout 
	
	#zoom out, bbeg becomes visible
	var start_zoom: float = 5
	var end_zoom: float = 3.765/1.6
	
	const lerp_secs = 300;
	for i in range(lerp_secs):
		await get_tree().create_timer(0.01).timeout
		var lerp_pos = float(i)/float(lerp_secs);
		var camera_2_zoom = lerp(start_zoom, end_zoom, lerp_pos)
		var camera_2_pos = camera_start.lerp(Vector2(25, 0), lerp_pos)
		$Camera2D.set_position(camera_2_pos)
		$Camera2D.zoom = Vector2(camera_2_zoom, camera_2_zoom)
	
	
	await get_tree().create_timer(2).timeout 
	print("TEMP necromancer summons characters")
		
	var ai_counter :=0
	Singleton.player_position = Vector2(0,300)
	for i in all_ai_char_instances:
		if i.dead and not i.fully_dead:
			i.boss_fight = true
			i.necromancy()
			i.position = Vector2 (ai_counter%6*20,ai_counter/6 *20) +Vector2(-20,-20)
			ai_counter += 1
			print(ai_counter)

	await get_tree().create_timer(2).timeout 
	print("fight starts")
	Singleton.current_character=boss_instance

# Linear interpolation
func lerp(a, b, t):
	return a + (b-a) * t
		
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
	var scene = preload("res://Scenes/AIChar.tscn")
	var instance = scene.instantiate()
	instance.position = Vector2(1000,1000)
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
	print("TEMP all ai dead, starting second phase")
	await get_tree().create_timer(2).timeout
	Singleton.current_character=boss_instance
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
		
