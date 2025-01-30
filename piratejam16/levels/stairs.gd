extends Area2D

func _ready():
	# Connect the area entered signal
	body_entered.connect(_on_body_entered)
	
	if get_node_or_null("Sprite2D") == null:
		var sprite = Sprite2D.new()
		# Load your stair texture
		var texture = load("res://assets/tiles/stair.png")
		sprite.texture = texture
		add_child(sprite)

func _on_body_entered(body):
	if body.is_in_group("player"):
		var map = get_tree().get_root().get_node("/root/Game/Map")
		map.next_floor()
