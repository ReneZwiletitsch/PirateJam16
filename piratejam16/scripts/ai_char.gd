extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("TEST")
	var current_char := AIcharacter.new()
	print(current_char.hp)
	

	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass






var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()






class AIcharacter:
	#stats 
	var rng = RandomNumberGenerator.new()
	var hp := rng.randi_range(1, 100)
	var strenght := rng.randi_range(1, 100)
	var speed := rng.randi_range(1, 100)
	var dex := rng.randi_range(1, 100)
	var willpower := rng.randi_range(1, 100)
	

	
