extends Node


@onready var text_box_scene = preload("res://Scenes/text_box.tscn")

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialogue_active = false
var can_advance_line = false

var mouse_position

# Don't need Player node anymore since we're not using it
func start_dialogue(pos: Vector2, lines: Array[String]):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	text_box_position = pos
	_show_text_box(true)
	
	is_dialogue_active = true

func pop_up(pos: Vector2, lines: Array[String]):
	mouse_position = pos
	
	if is_instance_valid(text_box):
		# Check if text box already exists. 
		_update_to_mouse()
		text_box.display_text(lines[0], false)
	else:
		dialogue_lines = lines
		# show the text: Not dialogue
		_show_text_box(false)

	
func _show_text_box(is_dialogue):
	text_box = text_box_scene.instantiate()
	get_tree().get_root().add_child(text_box)
	
	if is_dialogue:
		text_box.finished_displaying.connect(_on_text_box_finished_displaying)
		_update_text_box_position()
		text_box.display_text(dialogue_lines[current_line_index], is_dialogue)
		can_advance_line = false
	else:
		_update_to_mouse()
		text_box.display_text(dialogue_lines[current_line_index], is_dialogue)

func _process(delta: float) -> void:
	if is_dialogue_active and text_box and text_box_position:
		_update_text_box_position()
	elif not is_dialogue_active and text_box and text_box_position:
		_update_to_mouse()

func _update_text_box_position():
	if text_box and text_box_position:
		text_box.global_position = text_box_position + Vector2(-45, -25)

func _update_to_mouse():
	if mouse_position:
		text_box.global_position = mouse_position - Vector2(0, 15)

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
			
		_show_text_box(true)
	elif (event.is_action_pressed("skip_dialogue")):
		fuck_this_shit()


func fuck_this_shit():
	if is_instance_valid(text_box):
		current_line_index = 0
		is_dialogue_active = false
		text_box.queue_free()
