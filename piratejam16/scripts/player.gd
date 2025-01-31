class_name Player
extends CharacterBody2D


func _ready() -> void:
	call_deferred("_start_dialogue")
	add_to_group("player")

func _start_dialogue():
	DialogueManager.start_dialogue(self, Singleton.all_dialogue[Singleton.dialogue_index])
