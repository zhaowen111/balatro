# fapai.gd
extends Node

@export var rotation_with_mark: float = 5.0
@onready var hand_container = $CardContainer
@onready var mark2d: Marker2D = $Marker2D

var deck: Array[Card] = []
var player_hand: Array[Card] = []
var _texture_cache: Dictionary = {}

const CardScene = preload("res://scenes/test/normal_cards/cardScene.tscn")

func _ready() -> void:
	create_deck()

func create_deck() -> void:
	deck.clear()
	var suits = ["s", "h", "c", "d"]
	var ranks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
	var chip_map = {
		"1": 11, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
		"10": 10, "11": 10, "12": 10, "13": 10
	}

	for suit in suits:
		for rank in ranks:
			var card = Card.new()
			card.rank = rank
			card.suit = suit
			card.chip_value = chip_map[rank]
			var texture_path = "res://sprites/plain_cards/%s%s.png" % [suit, rank]
			card.texture = _load_card_texture(texture_path)
			deck.append(card)

func _load_card_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]
	var texture = load(path) as Texture2D
	if texture == null:
		push_warning("无法加载卡牌纹理: %s" % path)
		return null
	_texture_cache[path] = texture
	return texture

func fapai() -> void:
	deal_cards(8)
	display_hand()

func deal_cards(num: int) -> void:
	for card in player_hand:
		deck.append(card)
	player_hand.clear()

	if deck.size() < num:
		push_warning("牌库不足 %d 张，重新创建牌库" % num)
		create_deck()

	deck.shuffle()
	player_hand = deck.slice(0, num)
	deck = deck.slice(num)
	player_hand.sort_custom(func(a, b): return int(a.rank) < int(b.rank))

func display_hand() -> void:
	var hand_global = hand_container.global_position
	var mark_global = mark2d.global_position
	var radius = abs(hand_global.y - mark_global.y)

	for child in hand_container.get_children():
		hand_container.remove_child(child)
		child.free()

	var hand_count = player_hand.size()
	var mid_count = hand_count / 2.0

	for i in range(hand_count):
		var card = player_hand[i]
		var card_node: Node2D = CardScene.instantiate()
		card_node.mark2d = mark2d

		var degree = (i - mid_count) * rotation_with_mark
		card_node.rotation_degrees = degree
		var angle_rad = deg_to_rad(degree - 90.0)
		var card_global_pos = Vector2(
			mark_global.x + cos(angle_rad) * radius,
			mark_global.y + sin(angle_rad) * radius
		)
		card_node.position = hand_container.to_local(card_global_pos)

		hand_container.add_child(card_node)
		card_node.setup(card)
