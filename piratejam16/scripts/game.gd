extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _input(event):
	if event.is_action_pressed("pause"):
		print("paused")
		get_tree().paused = true
		$Camera2D/PauseScreen.visible = true

func _on_unpause_button_button_down() -> void:
	get_tree().paused = false
	$Camera2D/PauseScreen.visible = false


func _on_quit_to_main_menu_button_button_down() -> void:
	DialogueManager.fuck_this_shit()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
