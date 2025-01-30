extends NodeState
@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

var direction: Vector2
static var speed: int = 50

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	direction = GameInputEvents.movement_input()
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true
		
	player.velocity = direction * speed
	player.move_and_slide()
	

func _on_next_transitions() -> void:
	if not GameInputEvents.is_movement_input():
		transition.emit("Idle")
	
func _on_enter() -> void:
	animated_sprite_2d.play("walking")
	
func _on_exit() -> void:
	animated_sprite_2d.stop()
