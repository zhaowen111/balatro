extends PanelContainer

var is_selected = false
var card: Card = null
var texture_button: TextureButton = null
signal card_selected(card: Card)
signal card_deselected(card: Card)

func _on_texture_button_pressed() -> void:
	if (is_selected):
		position = position + Vector2(0, 20)
		card_deselected.emit(card)
		CardManager.selected_cards.erase(card)
	else:
		position = position + Vector2(0, -20)
		card_selected.emit(card)
		CardManager.selected_cards.append(card)
	is_selected = !is_selected

func select_card() -> void:
	is_selected = true
	card_selected.emit(card)
	CardManager.selected_cards.append(card)

func deselect_card() -> void:
	is_selected = false
	card_deselected.emit(card)
	CardManager.selected_cards.erase(card)


func setup(_card: Card) -> void:
	self.card = _card
	$TextureButton.texture_normal = card.texture
	# $TextureButton.texture_pressed = card.texture
	# $TextureButton.texture_hover = card.texture
