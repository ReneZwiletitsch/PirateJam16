extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_again_button_button_down() -> void:
	#reset singleton file
	Singleton.set_script(null)
	Singleton.set_script(preload("res://scripts/Singleton.gd"))
	get_tree().change_scene_to_file("res://game.tscn")


func _on_quit_to_main_menu_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
