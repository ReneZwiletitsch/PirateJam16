extends NodeState
@export var player: Player
@export var animatedSprite: AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass
	

func _on_physics_process(_delta : float) -> void:
	pass

func _on_next_transitions() -> void:
	GameInputEvents.movement_input()
	
	if GameInputEvents.resurrect():
		transition.emit("Resurrect")
	elif GameInputEvents.is_movement_input():
		transition.emit("Walking")
	
func _on_enter() -> void:
	pass
	
	
func _on_exit() -> void:
	pass
