extends NodeState
@export var player: Player
@export var animatedSprite: AnimatedSprite2D

static var speed: int = 50

func _on_process(_delta : float) -> void:
	pass
	

func _on_physics_process(_delta : float) -> void:
	var direction = GameInputEvents.movement_input()
	
	if direction.x > 0:
		animatedSprite.flip_h = false
	elif direction.x < 0:
		animatedSprite.flip_h = true
		
	player.velocity = direction * speed
	player.move_and_slide()

func _on_next_transitions() -> void:
	if GameInputEvents.resurrect():
		transition.emit("Resurrect")
	
	
func _on_enter() -> void:
	pass
	
	
func _on_exit() -> void:
	pass
