extends NodeState


func _ready():
	event_bus.arise.connect(ariseCorpse)
	
func ariseCorpse() -> void:
	print("Corpse has arisen")

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	pass
	

func _on_next_transitions() -> void:
	pass
	
	
func _on_enter() -> void:
	event_bus.emit_signal("resSignal")
	
	
func _on_exit() -> void:
	pass
