class_name GameInputEvents

static var direction: Vector2

static func movement_input() -> Vector2:
	direction = Input.get_vector("left", "right", "up", "down")
	
	return direction

static func is_movement_input() -> bool:
	if direction.x == 0 and direction.y == 0:
		return true
	else:
		return false

static func resurrect() -> bool:
	if Input.is_action_just_pressed("resurrect"):
		print("E has been pressed")
		return true
	else:
		return false
	
