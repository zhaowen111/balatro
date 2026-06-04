extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func showToolTip(text: String, _position: Vector2) -> void:
	$message.text = text
	visible = true
	global_position = _position - size / 2 + Vector2(0, size.y / 2 + 40)

func hideToolTip() -> void:
	visible = false