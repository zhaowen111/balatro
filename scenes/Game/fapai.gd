# fapai.gd
extends Node

@export var rotation_with_mark: int = 5
@onready var hand_container = $CardContainer
@onready var mark2d: Marker2D = $Marker2D


const CardNode = preload("res://scenes/Game/Card/CardNode.tscn")
func fapai() -> void:
	CardManager.clear_player_hand()
	CardManager.deal_cards(8)
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


func play_card() -> void:
	var cardNodes = hand_container.get_children()
	# 将选中卡牌从容器中删除
	for cardNode in cardNodes:
		if cardNode.is_selected:
			hand_container.remove_child(cardNode)
			cardNode.free()
	var count = CardManager.play_card()
	CardManager.deal_cards(count)
	display_hand()