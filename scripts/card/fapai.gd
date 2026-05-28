# Main.gd
extends Node
@export var widthBili = 2.0/3.0
@export var rotationWithMark = 5.0
@onready var hand_container = $CardContainer
@onready var mark2d:Marker2D = $Marker2D

var deck: Array[Card] = []
var player_hand: Array[Card] = []
const CARD_WIDTH = 142
const CARD_HEIGHT = 190

func _ready():
	create_deck()
func create_deck():
	var suits = ["s", "h", "c", "d"]
	var ranks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
	# 筹码值可以自己定义，例如 A=1或11，JQK=10，其余按点数
	var chip_map = {
		"1": 11, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10, "11": 10, "12": 10, "13": 10
	}
	
	for suit in suits:
		for rank in ranks:
			var card = Card.new()
			card.rank = rank
			card.suit = suit
			card.chip_value = chip_map[rank]
			# 纹理加载：假设纹理放在 res://cards/ 路径，命名为 spade_A.png 等
			var texture_path = "res://sprites/plain_cards/%s%s.png" % [suit, rank]
			# 使用 load 或 preload，注意实际路径要存在
			card.texture = load(texture_path)
			deck.append(card)

func fapai():
	deal_cards(8)
	display_hand()
func deal_cards(num: int):
	# 随机抽取不重复的牌
	deck.shuffle()   # 洗牌
	player_hand = deck.slice(0, num)  # 取前 num 张
	player_hand.sort_custom(func(a,b):return int(a.rank) < int(b.rank))
	
	#deck = deck.slice(num)
	# 如果希望从原始牌库中移除，可以：deck = deck.slice(num)

func print_player_hand():
	for card in player_hand:
		print("%s of %s, chip: %d" % [card.rank, card.suit, card.chip_value])

const CardScene = preload("res://prefabs/normal_cards/cardScene.tscn")
func display_hand():
	# 获取全局坐标
	var hand_global = hand_container.global_position
	var mark_global = mark2d.global_position

	# 计算半径（全局坐标下的垂直距离）
	var radius = abs(hand_global.y - mark_global.y)
	print("半径:", radius)
	print("mark2d 全局位置:", mark_global)

	# 清空原有卡片
	for child in hand_container.get_children():
		child.queue_free()

	var handCount = player_hand.size()
	var midCount = handCount / 2.0

	for i in range(handCount):
		var card = player_hand[i]
		var card_node: Node2D = CardScene.instantiate()
		card_node.call_deferred("setup", card)
		card_node.mark2d = mark2d

		var degree = (i - midCount) * rotationWithMark
		card_node.rotation_degrees += degree
		var degree1 = degree - 90
		# 计算圆上的全局坐标位置
		var card_global_pos = Vector2(
			mark_global.x + cos(deg_to_rad(degree1)) * radius,
			mark_global.y + sin(deg_to_rad(degree1)) * radius
		)

		# 转换为 hand_container 的局部坐标（因为要添加到 hand_container 下）
		card_node.position = hand_container.to_local(card_global_pos)

		print("卡片", i, "位置（局部）:", card_node.position)
		print("卡片", i, "位置（全局）:", card_node.global_position)
		# 可选：添加鼠标事件
		# card_node.mouse_entered.connect(_on_card_hover.bind(card_node))
		# card_node.mouse_exited.connect(_on_card_unhover.bind(card_node))
		
		hand_container.add_child(card_node)


# 可选：悬停效果
func _on_card_hover(panel: Panel):
	panel.scale = Vector2(1.05, 1.05)
	panel.modulate = Color(1.2, 1.2, 1.2)

func _on_card_unhover(panel: Panel):
	panel.scale = Vector2(1, 1)
	panel.modulate = Color(1, 1, 1)
