class_name MyBaseButton
extends Button

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down() -> void:
	get_tree().create_tween().tween_property(self,"position:y",position.y+10,0.1)

func _on_button_up() -> void:
	get_tree().create_tween().tween_property(self,"position:y",position.y-10,0.1)
