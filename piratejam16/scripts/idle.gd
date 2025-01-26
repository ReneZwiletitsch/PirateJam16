extends NodeState
@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta : float) -> void:
	pass
	

func _on_physics_process(_delta : float) -> void:
	pass
	

func _on_next_transitions() -> void:
	GameInputEvents.movement_input()
	
	if GameInputEvents.is_movement_input():
		transition.emit("Walking")
	
	
func _on_enter() -> void:
	animated_sprite_2d.play("idle")
	
	
func _on_exit() -> void:
	animated_sprite_2d.stop()
