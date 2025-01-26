extends CharacterBody2D


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var movement_speed: float = 200.0
var willpower: float=0
var movement_target_position: Vector2 = Vector2(0.0,0.0)

@onready var current_char := AIcharacter.new()

#flags
@onready var playercontrol = false
@onready var dead = true
@onready var fully_dead := false


@onready var attack_rdy := true
@onready var aim
@onready var target_polygon = Polygon2D.new()
@onready var last_animation = "alive_idle"

signal player_attack_woundup(aim)


#temp
@onready var test := true

@onready var test2



func debug_message():
	print(dead)



func necromancy():
	if not dead and playercontrol:
		$AnimatedSprite2D.set_animation("dead")
		Singleton.player_position = global_position
		Singleton.current_player_hp = 0
		Singleton.current_player_strenght = 0
		Singleton.current_player_dex = 0
		Singleton.current_character = null
		dead = true
		playercontrol = false
	
	elif get_local_mouse_position().length() < 32 and dead and not fully_dead and (global_position-Singleton.player_position).length() <Singleton.necromancy_range and Singleton.current_character == null:
		print("did a necromancy")		
		$AnimatedSprite2D.set_animation("undead_idle")
		Singleton.player_died = false
		Singleton.current_character = $"."
		dead = false
		playercontrol = true
		Singleton.current_player_hp = current_char.curr_hp
		Singleton.current_player_strenght = current_char.strenght
		Singleton.current_player_dex = current_char.dex
		print("player now has this hp: ",Singleton.current_player_hp)
		print("player now has this str: ",Singleton.current_player_strenght)
				

	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	add_child(target_polygon)
	var cone_corners := PackedVector2Array([])
	var radius_vector := Vector2(Singleton.basic_character_range,0)
	cone_corners.append(Vector2(0,0))
	for i in range(21):
		cone_corners.append(radius_vector.rotated(Singleton.basic_attack_angle*i/10))
	target_polygon.set_polygon(cone_corners)	
	target_polygon.set_color(Color(0, 1, 1, .5))
	
	$CollisionShape2D.disabled = true
	
	
	movement_speed = current_char.speed
	willpower = current_char.willpower
	
	#idk what these do, they are from the documentation
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playercontrol and Singleton.player_died:
		print("player just died, doing fully_dead thing")
		fully_dead = true
		dead = true
		Singleton.current_character = null
		Singleton.player_position = global_position+ Vector2(10,0)
		$AnimatedSprite2D.set_animation("deadge")
		print("end of the function")
		playercontrol = false
		
	elif playercontrol and attack_rdy:
		aim = Singleton.current_character.get_local_mouse_position().normalized()
		target_polygon.rotate(aim.angle()-target_polygon.get_rotation()-PI/4)		
	

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target



func character_damage():
	if (global_position-Singleton.current_character.global_position).length()<Singleton.basic_character_range and not playercontrol and not dead:
		current_char.curr_hp -= Singleton.current_player_strenght
		print("character got dmg",current_char.curr_hp)
		if current_char.curr_hp <=0:
			dead = true
			print("character has died")
			current_char.curr_hp = current_char.max_hp
			$AnimatedSprite2D.set_animation("dead")



func attack():
	attack_rdy = false
	$Attack_timer.start(Singleton.max_attack_cooldown/current_char.dex)
	if not playercontrol:
		aim = (Singleton.current_character.global_position-global_position).normalized()
		target_polygon.rotate(aim.angle()-target_polygon.get_rotation()-PI/4)
	else:
		aim = Singleton.current_character.get_local_mouse_position().normalized()
		target_polygon.rotate(aim.angle()-target_polygon.get_rotation()-PI/4)
		
func _on_attack_timer_timeout() -> void:
	$Attack_timer.stop()
	attack_rdy = true
	#ai attack
	if not playercontrol and Singleton.current_character != null:
		#check if player is in cone, basically same as other way around

		var enemy_pos = Singleton.current_character.global_position-global_position
		var enemy_vec = enemy_pos.normalized()
		if abs(acos(aim.dot(enemy_vec))) < Singleton.basic_attack_angle and enemy_pos.length()< Singleton.basic_character_range:
			Singleton.player_damage(current_char.strenght)
			
		else:
			print("player dodged")
			print(enemy_pos.length())
			pass

	elif playercontrol:
		player_attack_woundup.emit(aim)




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
			movement_target_position = Vector2(0.0,0.0)
			set_movement_target(movement_target_position)
			
	
		#if we are in range of the player, stop walking and attack
		if not dead and current_agent_position.distance_to(movement_target_position) < Singleton.basic_character_range*0.5 and attack_rdy and not playercontrol: #temp 0.5 means they don't attack at the edge of their range and miss all the time
			AI_input = Vector2(0,0)
			if not playercontrol:
				attack()
				
		#if we are the player and at ai's target, stop ai input
		elif playercontrol and current_agent_position.distance_to(Vector2(0.0,0.0))<Singleton.basic_character_range:
			AI_input = Vector2(0,0)

	else:
		AI_input = Vector2(0,0)


	if not dead and attack_rdy:
		#if the player doesn't input anything, follow a path at full speed, otherwise battle the player over control
		if (player_input_direction == Vector2(0,0) or not playercontrol):
			velocity = AI_input * movement_speed
		else:
			velocity = (AI_input * willpower + player_input_direction*(1-willpower))* movement_speed # *1.5 if we want to make player character faster. but for now i'll keep it the same, this way switching characters is important in combat
		
		var animation_name := ""
		
		
		if playercontrol:
			animation_name += "undead_walking"
		else:
			animation_name += "alive_walking"
			
		if velocity[0]>0:
			animation_name += "_right"
		else:
			animation_name +="_left"

		if animation_name != last_animation:
			$AnimatedSprite2D.set_animation(animation_name)
			last_animation = animation_name
		move_and_slide()




class AIcharacter:
	#stats 
	var rng = RandomNumberGenerator.new()
	var max_hp :=  rng.randi_range(1, 100)
	var strenght := rng.randi_range(1, 10)
	var speed := rng.randi_range(50, 100)
	var dex := rng.randi_range(1, 100)
	var willpower := rng.randf_range(0, 0.2)
	var curr_hp := max_hp


	
	
