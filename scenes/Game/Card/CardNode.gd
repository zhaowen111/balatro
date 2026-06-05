extends PanelContainer

var is_selected = false
var card: Card = null
var texture_button: TextureButton = null
signal card_selected(card: Card)
signal card_deselected(card: Card)

func _on_texture_button_pressed() -> void:
	if (is_selected):
		deselect_card()
	else:
		select_card()

func select_card() -> void:
	if (CardManager.selected_cards.size() >= 5):
		return
	position = position + Vector2(0, -CardManager.card_up_offset)
	is_selected = true
	card_selected.emit(card)
	CardManager.select_card(card)

func deselect_card() -> void:
	is_selected = false
	position = position + Vector2(0, CardManager.card_up_offset)
	card_deselected.emit(card)
	CardManager.unselect_card(card)


func setup(_card: Card) -> void:
	self.card = _card
	$TextureButton.texture_normal = card.texture
	# $TextureButton.texture_pressed = card.texture
	# $TextureButton.texture_hover = card.texture
