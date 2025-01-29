class_name Player
extends CharacterBody2D


func _ready() -> void:
	call_deferred("_start_dialogue")

func _start_dialogue():
	DialogueManager.start_dialogue(self, Singleton.how_to_play)
