class_name ResurrectSlime
extends Area2D

var player: bool

func _ready() -> void:
	event_bus.resSignal.connect(is_resurrecting)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Player has entered area of slime.")
		player = true
	else:
		player = false

func is_resurrecting() -> void:
	if player == true:
		print("resurrecting")
		event_bus.emit_signal("arise")
