extends Camera2D

class_name LevelEditorCam

var ZoomMin = Vector2(0.25,0.25)
var ZoomMax = Vector2(5.,5.)
var ZoomSpd = Vector2(0.3,0.3)
var PanSpeedKey = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ScrollZoomOut"):
		if zoom > ZoomMin:
			zoom -= ZoomSpd
		print("Zoom out")
	if event.is_action_pressed("ScrollZoomIn"):
		if zoom < ZoomMax:
			zoom +=ZoomSpd
		print("Zoom in")
	print(zoom)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("up"):
		position.y -= PanSpeedKey
	if Input.is_action_pressed("down"):
		position.y += PanSpeedKey
	if Input.is_action_pressed("left"):
		position.x -= PanSpeedKey
	if Input.is_action_pressed("right"):
		position.x += PanSpeedKey
	pass
