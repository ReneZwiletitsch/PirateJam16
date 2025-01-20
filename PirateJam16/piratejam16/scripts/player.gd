extends CharacterBody2D
@onready var characterSprite: AnimatedSprite2D = $AnimatedSprite2D


const SPEED = 100.0
# const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Worry about gravity later if needed
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Not worried about jumping atm
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction.x < 0:
		characterSprite.flip_h = true
	elif direction.x > 0:
		characterSprite.flip_h = false
	velocity = direction * SPEED

	move_and_slide()
