extends CharacterBody2D


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(0.0,0.0)
var willpower: float=0
@onready var playercontrol = false


func _input(event):
	if event.is_action_pressed("test"):
		playercontrol = true
		
		#this is how to set a new target position
		movement_target_position = Vector2(0.0,0.0)
		set_movement_target(movement_target_position)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("TEST")
	var current_char := AIcharacter.new()
	movement_speed = current_char.speed
	willpower = current_char.willpower
	
	#idk what these do, they are from the documentation
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred(movement_target_position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func actor_setup(movement_target_position):
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _physics_process(delta):
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var player_input_direction := Input.get_vector("left", "right", "up", "down")
	var AI_input := current_agent_position.direction_to(next_path_position)
	
	#if navigation_agent.is_navigation_finished():
	if current_agent_position.distance_to(movement_target_position) < 2:
		AI_input = Vector2(0,0)
	
	#if the player doesn't input anything, follow a path at full speed, otherwise battle the player over control
	if (player_input_direction == Vector2(0,0) or not playercontrol):
		velocity = AI_input * movement_speed
	else:
		velocity = (AI_input * willpower + player_input_direction*(1-willpower))* movement_speed
	
	
	move_and_slide()



class AIcharacter:
	#stats 
	var rng = RandomNumberGenerator.new()
	var hp := rng.randi_range(1, 100)
	var strenght := rng.randi_range(1, 100)
	var speed := 100#rng.randi_range(1, 100)
	var dex := rng.randi_range(1, 100)
	var willpower := 0.1#rng.randf_range(0, 0.1)
	

	
	
