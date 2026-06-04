extends Node

var deck: Array[Card] = []
var player_hand: Array[Card] = []
var default_deck: Array[Card] = []
# 已使用牌库
var used_cards: Array[Card] = []
var selected_cards: Array[Card] = []
var SORT_CARD_BY_RANK = true

func _ready() -> void:
	initCardManager()


func initCardManager() -> void:
	default_deck = create_default_deck()
	deck = default_deck.duplicate()


# 创建52个共包含2张牌的对象
func create_default_deck() -> Array[Card]:
	var temp_deck: Array[Card] = []
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
			card.texture = TextureUtils.load_card_texture(texture_path)
			temp_deck.append(card)
	return temp_deck

# 发牌、牌不够时重新创建牌库
func deal_cards(num: int) -> Array[Card]:
	if deck.size() < num:
		push_warning("牌库不足 %d 张，重新创建牌库" % num)
		deck = default_deck.duplicate()

	deck.shuffle()
	player_hand += deck.slice(0, num)
	deck = deck.slice(num)
	if SORT_CARD_BY_RANK:
		player_hand.sort_custom(func(a, b): return int(a.rank) < int(b.rank))
	else:
		player_hand.sort_custom(func(a, b): return a.suit < b.suit)
	return player_hand

func add_to_deck(card: Card) -> void:
	deck.append(card)

func create_random_card() -> Card:
	var random_card = default_deck.pick_random()
	random_card.random_card_type()
	return random_card

func play_card() -> int:
	var count = selected_cards.size()
	if count == 0:
		return 0
	for card in selected_cards:
		player_hand.erase(card)
	used_cards.append_array(selected_cards)
	selected_cards.clear()
	return count

func select_card(card: Card) -> void:
	selected_cards.append(card)

func unselect_card(card: Card) -> void:
	selected_cards.erase(card)

func clear_selected_cards() -> void:
	selected_cards.clear()

func clear_player_hand() -> void:
	player_hand.clear()