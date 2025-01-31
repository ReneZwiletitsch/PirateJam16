extends Node


@onready var text_box_scene = preload("res://Scenes/text_box.tscn")

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Node2D

var is_dialogue_active = false
var can_advance_line = false


func start_dialogue(player: Node2D, lines: Array[String]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	text_box_position = player
	_show_text_box()
	
	is_dialogue_active = true


func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().get_root().add_child(text_box)
	
	_update_text_box_position()
	text_box.display_text(dialogue_lines[current_line_index])
	can_advance_line = false
	

func _process(delta: float) -> void:
	if is_dialogue_active and text_box and text_box_position:
		_update_text_box_position()

func _update_text_box_position():
	if text_box and text_box_position:
		text_box.global_position = text_box_position.global_position + Vector2(-45, -25)

func _on_text_box_finished_displaying():
	can_advance_line = true

func _unhandled_input(event):
	if (event.is_action_pressed("advance_dialogue") and is_dialogue_active and can_advance_line):
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			return
			
		_show_text_box()
		
		
func fuck_this_shit():
	if is_instance_valid(text_box):
		is_dialogue_active = false
		text_box.queue_free()
