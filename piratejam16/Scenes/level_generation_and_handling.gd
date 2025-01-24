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

	#player attacking
	elif event.is_action_pressed("attack"):
		print(Singleton.has_character)
		if Singleton.has_character:
			var can_attack = false
			for i in all_ai_char_instances:
				if i.playercontrol and i.attack_rdy:
					can_attack = true
						
			if can_attack:	
				for i in all_ai_char_instances:
					i.character_damage()
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
