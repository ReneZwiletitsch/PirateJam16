class_name GameInputEvents

static var direction: Vector2

static func movement_input() -> Vector2:
	direction = Input.get_vector("left", "right", "up", "down")
	
	return direction
	
	
static func is_movement_input() -> bool:
	if direction != Vector2(0, 0):
		return true
	else:
		return false
