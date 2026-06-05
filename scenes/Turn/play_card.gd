# fapai.gd
extends Node

@export var rotation_with_mark: int = 5
@onready var hand_container = $CardContainer
@onready var mark2d: Marker2D = $Marker2D

func _ready() -> void:
	CardManager.clear_player_hand()
	CardManager.deal_cards(MyPlayerAssets.maxHandCount)
	display_hand()

const CardNode = preload("res://scenes/Game/Card/CardNode.tscn")
func deal_cards(count: int) -> void:
	CardManager.deal_cards(count)
	display_hand()


func display_hand() -> void:
	var hand_global = hand_container.global_position
	var mark_global = mark2d.global_position
	var radius = abs(hand_global.y - mark_global.y)

	for child in hand_container.get_children():
		hand_container.remove_child(child)
		child.free()

	var hand_count = CardManager.player_hand.size()
	var mid_count = hand_count / 2.0

	for i in range(hand_count):
		var card = CardManager.player_hand[i]
		var card_node = CardNode.instantiate()

		var degree = (i - mid_count) * rotation_with_mark
		card_node.rotation_degrees = degree
		var angle_rad = deg_to_rad(degree - 90.0)
		var card_global_pos = Vector2(
			mark_global.x + cos(angle_rad) * radius,
			mark_global.y + sin(angle_rad) * radius
		)
		card_node.position = hand_container.to_local(card_global_pos)
		card_node.setup(card)
		hand_container.add_child(card_node)

signal playCardSignal
func play_card() -> void:
	if (CardManager.selected_cards.size() == 0 or MyPlayerAssets.playCount <= 0):
		return
	MyPlayerAssets.playCount -= 1
	_remove_selected_cards()
	var _cards = CardManager.play_card()
	var score_context = CardManager.evaluate_hand(_cards)
	var hand_scored_cards = score_context.hand_scored_cards
	var primary_hand = hand_scored_cards[score_context.primary_hand]
	var chips = score_context.base_chips
	var mult = score_context.base_mult
	for card in primary_hand:
		chips += card.chip_value
	MyPlayerAssets.allScore += chips * mult
	display_hand()
	playCardSignal.emit()
	deal_cards(_cards.size())

signal discardCardSignal
func discard_card() -> void:
	if (CardManager.selected_cards.size() == 0 or MyPlayerAssets.discardCount <= 0):
		return
	MyPlayerAssets.discardCount -= 1
	_remove_selected_cards()
	var _cards = CardManager.discard_cards()
	display_hand()
	discardCardSignal.emit()
	deal_cards(_cards.size())


func _remove_selected_cards() -> void:
	var cardNodes = hand_container.get_children()
	for cardNode in cardNodes:
		if cardNode.is_selected:
			hand_container.remove_child(cardNode)
			cardNode.free()

func deselect_all_cards() -> void:
	var cardNodes = hand_container.get_children()
	for cardNode in cardNodes:
		if cardNode.is_selected:
			cardNode.deselect_card()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("取消选择"):
		deselect_all_cards()
		print(11111)
