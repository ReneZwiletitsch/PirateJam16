extends CharacterBody2D


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(0.0,0.0)

@onready var current_char := AIcharacter.new()

#flags
@onready var playercontrol = false
@onready var dead = true
@onready var fully_dead := false
@onready var texture_type := "alive"
@onready var character_index :=0
@onready var attack_range := Singleton.basic_character_range

@onready var attack_rdy := true
@onready var aim
@onready var target_polygon = Polygon2D.new()
@onready var last_animation = ""
@onready var last_direction = "right"


signal player_attack_woundup(aim,boss)

@onready var boss_fight := false

enum character {alive,dead,undead,fully_dead,fighting_boss,boss,necromancer}
enum attribute {character_index,dead,fully_dead,playercontrol,texture_type,attack_range}
var attribute_list = [
			[0,false,false,false,"alive",Singleton.basic_character_range], #alive
			[1,true,false,false,"dead",Singleton.basic_character_range], #dead
			[2,false,false,true,"undead",Singleton.basic_character_range], #undead
			[3,true,true,false,"deadge",0], #fully dead
			[4,false,false,false,"fighting_boss",Singleton.basic_character_range], #fighting boss
			[5,false,false,false,"boss",Singleton.basic_character_range*2], #boss
			[6,true,false,true,"necromancer",Singleton.basic_character_range], #necromancer
			]


func load_attributes(char_to_load):
	#set the attributes
	playercontrol = attribute_list[char_to_load][attribute.playercontrol]
	dead = attribute_list[char_to_load][attribute.dead]
	fully_dead = attribute_list[char_to_load][attribute.fully_dead]
	texture_type = attribute_list[char_to_load][attribute.texture_type]
	character_index = attribute_list[char_to_load][attribute.character_index]
	last_animation = texture_type+"_idle_right"
	attack_range = attribute_list[char_to_load][attribute.attack_range]
	$AnimatedSprite2D.set_animation(texture_type+"_idle_right")
	

func necromancy():
	if not dead and playercontrol:
		load_attributes(character.dead)
		Singleton.player_position = global_position + Vector2(0,40)
		Singleton.current_player_hp = 0
		Singleton.current_player_strenght = 0
		Singleton.current_player_dex = 0
		Singleton.current_character = null
		remove_from_group("player")
	
	elif (get_local_mouse_position().length() < 32 and dead and not fully_dead and (global_position-Singleton.player_position).length() <Singleton.necromancy_range and Singleton.current_character == null) or boss_fight:				
		add_to_group("player")
		if boss_fight:
			load_attributes(character.fighting_boss)
		else:
			load_attributes(character.undead)
			Singleton.player_died = false
			Singleton.current_character = $"."
			Singleton.current_player_hp = current_char.curr_hp
			Singleton.current_player_strenght = current_char.strenght
			Singleton.current_player_dex = current_char.dex



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cone_corners := PackedVector2Array([])
	var radius_vector := Vector2(attack_range,0)
	cone_corners.append(Vector2(0,0))
	for i in range(21):
		cone_corners.append(radius_vector.rotated(Singleton.basic_attack_angle*i/10))
	target_polygon.set_polygon(cone_corners)	
	target_polygon.set_color(Color(0, 1, 1, .5))
	target_polygon.visible = false
	add_child(target_polygon)
	
	#$CollisionShape2D.disabled = true
	
	movement_speed = current_char.speed
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0	#idk what these do, they are from the documentation
	navigation_agent.target_desired_distance = 4.0
	# Make sure to not await during _ready.
	actor_setup.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#temp, this should probably be handled elsewhere
	if playercontrol and Singleton.player_died:
		print("player just died, doing fully_dead thing")
		load_attributes(character.fully_dead)
		Singleton.current_character = null
		Singleton.player_position = global_position+ Vector2(0,40)
		self.set_scale(Vector2(0.5,0.5))
		self.position += Vector2(0,16)
		self.set_z_index(0)


func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func character_damage():
	if (global_position-Singleton.current_character.global_position).length()<attack_range and not playercontrol and not dead:
		current_char.curr_hp -= Singleton.current_player_strenght
		print("character got dmg",current_char.curr_hp)
		var scene = preload("res://Scenes/damage_indicator.tscn")
		var instance = scene.instantiate()
		add_child(instance,true)
		instance.label.text = str(Singleton.current_player_strenght)
		if character_index ==	attribute_list[character.alive][attribute.character_index]:
			instance.label.set("theme_override_colors/font_color", Color(1, 0, 1, 1))
			
		elif character_index ==	attribute_list[character.fighting_boss][attribute.character_index]:
			instance.label.set("theme_override_colors/font_color", Color.YELLOW)
		
		
		
		
		if current_char.curr_hp <=0:
			print("character has died")
			current_char.curr_hp = current_char.max_hp
			#if the character is undead go to fully dead, if alive go to dead
			if character_index == attribute_list[character.alive][attribute.character_index]:
				load_attributes(character.dead)
			elif character_index == attribute_list[character.fighting_boss][attribute.character_index]:
				load_attributes(character.fully_dead)
				self.set_scale(Vector2(0.5,0.5))
				self.position += Vector2(0,16)
				self.set_z_index(0)


func attack():
	attack_rdy = false
	target_polygon.visible = true
	$Attack_timer.start(Singleton.max_attack_cooldown/current_char.dex)
	last_animation = texture_type+"_idle_"+last_direction
	$AnimatedSprite2D.set_animation(last_animation)
	if character_index == attribute_list[character.undead][attribute.character_index] or character_index == attribute_list[character.necromancer][attribute.character_index]: #me
		aim = self.get_local_mouse_position().normalized()
	elif character_index ==	attribute_list[character.boss][attribute.character_index]: #boss
		#temp, random attacks
		var rng = RandomNumberGenerator.new()
		aim = Vector2(rng.randf_range(-1, 1),rng.randf_range(-1, 1)).normalized()
	else:
	 	#default #enemy and fighting boss
		aim = (Singleton.current_character.global_position-global_position).normalized()

	target_polygon.rotate(aim.angle()-target_polygon.get_rotation()-PI/4)
		
		
		
		
		
func _on_attack_timer_timeout() -> void:
	$Attack_timer.stop()
	target_polygon.visible = false
	attack_rdy = true
	
	if character_index == attribute_list[character.undead][attribute.character_index] or character_index == attribute_list[character.necromancer][attribute.character_index]: #me
		player_attack_woundup.emit(aim,false)
	elif character_index == attribute_list[character.boss][attribute.character_index]: #boss
		player_attack_woundup.emit(aim,true)
	
	elif character_index == attribute_list[character.alive][attribute.character_index] and Singleton.current_character != null: #alive
		var enemy_pos = Singleton.current_character.global_position-global_position
		var enemy_vec = enemy_pos.normalized()
		if abs(acos(aim.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< attack_range:
			Singleton.player_damage(current_char.strenght)
			var scene = preload("res://Scenes/damage_indicator.tscn")
			var instance = scene.instantiate()
			add_child(instance,true)
			instance.label.text = str(current_char.strenght)
			instance.label.set("theme_override_colors/font_color", Color.YELLOW)
			instance.global_position = Singleton.current_character.global_position
			
	elif character_index == attribute_list[character.fighting_boss][attribute.character_index] and Singleton.current_character != null: #fighting boss
		var enemy_pos = Singleton.current_character.global_position-global_position
		var enemy_vec = enemy_pos.normalized()
		if abs(acos(aim.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< attack_range:
			Singleton.boss_damage(current_char.strenght)
			var scene = preload("res://Scenes/damage_indicator.tscn")
			var instance = scene.instantiate()
			add_child(instance,true)
			instance.label.text = str(current_char.strenght)
			instance.label.set("theme_override_colors/font_color", Color(1, 0, 1, 1))
			instance.global_position = Singleton.current_character.global_position
			
		
		
	else:
		print("ERROR, SOMETHING WRONG WITH ATTACK")
		print("probably no character")
		





func _physics_process(delta):
	#walk towards player, except if you are possesed by the player; temp, should be dependent on sight range or something
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var player_input_direction := Input.get_vector("left", "right", "up", "down")
	var AI_input := current_agent_position.direction_to(next_path_position)

	if Singleton.current_character:
		if not playercontrol:
			movement_target_position = Singleton.current_character.global_position
			set_movement_target(movement_target_position)
			
		#temp, replace by logic where the player's body wants to go
		else:
			set_movement_target(movement_target_position)
			
	
		if not boss_fight or player_input_direction== Vector2(0,0):
			#if we are in range of the player, stop walking and attack
			if not dead and current_agent_position.distance_to(movement_target_position) < attack_range*0.5 and attack_rdy and not playercontrol: #temp 0.5 means they don't attack at the edge of their range and miss all the time
				AI_input = Vector2(0,0)
				if not playercontrol:
					attack()
					
			#if we are the player and at ai's target, stop ai input
			elif playercontrol and current_agent_position.distance_to(movement_target_position)<attack_range:
				AI_input = Vector2(0,0)

		if current_agent_position.distance_to(movement_target_position)>(Singleton.aggro_range + int(playercontrol)*100): #YES I AM USING A BOOLEAN AS A NUMBER. DON'T WORRY ABOUT IT
			AI_input = Vector2(0,0)
	else:
		AI_input = Vector2(0,0)
	
	if character_index == attribute_list[character.necromancer][attribute.character_index]:
		AI_input = Vector2(0,0)

	if not dead and attack_rdy:
		#if the player doesn't input anything, follow a path at full speed, otherwise battle the player over controldddddd
		if (player_input_direction == Vector2(0,0)) or (not playercontrol and not boss_fight):
			velocity = AI_input * movement_speed
		else:
			velocity = (AI_input * current_char.willpower + player_input_direction*(1-current_char.willpower))* movement_speed # *1.5 if we want to make player character faster. but for now i'll keep it the same, this way switching characters is important in combat
		
		
		move_and_slide()
		#changing animations
		var animation_name := texture_type
			
		if velocity[0]>0:
			animation_name += "_walking_right"
			last_direction = "right"
		elif velocity[0]<0:
			animation_name +="_walking_left"
			last_direction = "left"
		else:
			animation_name +="_idle_"
			animation_name += last_direction
		if animation_name != last_animation:
			$AnimatedSprite2D.set_animation(animation_name)
			last_animation = animation_name
			
	#	if character_index == attribute_list[character.boss][attribute.character_index]:
	#		print("boss is doing this: ")
	#		print(animation_name)
		

class AIcharacter:
	#stats 
	var rng = RandomNumberGenerator.new()
	var max_hp := rng.randi_range(1, 100)
	var strenght := rng.randi_range(1, 10)
	var speed := rng.randi_range(50, 100)
	var dex := rng.randi_range(1, 100)
	var willpower := rng.randf_range(0, 0.2)
	var curr_hp := max_hp
