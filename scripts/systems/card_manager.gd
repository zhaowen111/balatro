## 牌库与手牌管理，以及出牌牌型判定（Balatro 规则）
extends Node

# ---------------------------------------------------------------------------
# 运行时牌库状态
# ---------------------------------------------------------------------------

## 当前可抽牌库（发牌后剩余）
var deck: Array[Card] = []
## 玩家当前手牌
var player_hand: Array[Card] = []
## 完整 52 张标准牌库的模板（不会被发牌消耗，用于重置 deck）
var default_deck: Array[Card] = []
## 本局已打出 / 弃掉的牌，不再回到 deck
var used_cards: Array[Card] = []
## 玩家当前选中的待出牌 / 待弃牌
var selected_cards: Array[Card] = []
## true：手牌按点数排序；false：按花色排序
var SORT_CARD_BY_RANK = true

@export var card_up_offset: int = 40


func _ready() -> void:
	initCardManager()


## 初始化牌库：从 default_deck 复制一份作为当前 deck
func initCardManager() -> void:
	default_deck = create_default_deck()
	deck = default_deck.duplicate()


## 创建标准 52 张扑克牌
## rank 使用字符串 "1"~"13"（1=A，11=J，12=Q，13=K）
## suit 使用 "s"黑桃 / "h"红心 / "c"梅花 / "d"方片
func create_default_deck() -> Array[Card]:
	var temp_deck: Array[Card] = []
	var suits = ["s", "h", "c", "d"]
	var ranks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
	# Balatro 筹码：A=11，2~10 对应点数，J/Q/K=10
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


## 从 deck 发 num 张牌到手牌；deck 不足时从 default_deck 重新填充
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


## 从标准牌库随机取一张，并随机赋予增强 / 特殊效果
func create_random_card() -> Card:
	var random_card = default_deck.pick_random()
	random_card.random_card_type()
	return random_card


## 打出 selected_cards：从手牌移除并移入 used_cards
## @return 打出的张数，0 表示未选中任何牌
func play_card() -> Array[Card]:
	var count = selected_cards.size()
	var result = selected_cards.duplicate()
	if count == 0:
		return []
	for card in selected_cards:
		player_hand.erase(card)
	used_cards.append_array(selected_cards)
	selected_cards.clear()
	return result


## 弃牌：逻辑与 play_card 相同，区别由上层（TurnManager 等）区分
func discard_cards() -> Array[Card]:
	var count = selected_cards.size()
	var result = selected_cards.duplicate()
	if count == 0:
		return []
	for card in selected_cards:
		player_hand.erase(card)
	used_cards.append_array(selected_cards)
	selected_cards.clear()
	return result


func select_card(card: Card) -> void:
	selected_cards.append(card)


func unselect_card(card: Card) -> void:
	selected_cards.erase(card)


func clear_selected_cards() -> void:
	selected_cards.clear()


func clear_player_hand() -> void:
	player_hand.clear()


# ---------------------------------------------------------------------------
# 牌型常量（Balatro 1 级基础值，与 joker.json 中 hand_type 字符串一致）
# ---------------------------------------------------------------------------

## 牌型强度排序，数值越大越强（可用于比较或 UI 展示）
const HAND_PRIORITY: Dictionary = {
	"HIGH_CARD": 1,
	"PAIR": 2,
	"TWO_PAIR": 3,
	"THREE_OF_A_KIND": 4,
	"STRAIGHT": 5,
	"FLUSH": 6,
	"FULL_HOUSE": 7,
	"FOUR_OF_A_KIND": 8,
	"STRAIGHT_FLUSH": 9,
}

## 各牌型 1 级时的基础筹码 (chips) 与基础倍率 (mult)
const HAND_BASE: Dictionary = {
	"HIGH_CARD": {"chips": 5, "mult": 1},
	"PAIR": {"chips": 10, "mult": 2},
	"TWO_PAIR": {"chips": 20, "mult": 2},
	"THREE_OF_A_KIND": {"chips": 30, "mult": 3},
	"STRAIGHT": {"chips": 30, "mult": 4},
	"FLUSH": {"chips": 35, "mult": 4},
	"FULL_HOUSE": {"chips": 40, "mult": 4},
	"FOUR_OF_A_KIND": {"chips": 60, "mult": 7},
	"STRAIGHT_FLUSH": {"chips": 100, "mult": 8},
}

## 主牌型隐式包含的子牌型，供小丑「出牌包含 XX 牌型」条件判定
## 例：葫芦 (FULL_HOUSE) 同时触发「包含三条」和「包含对子」类效果
const HAND_CONTAINS: Dictionary = {
	"STRAIGHT_FLUSH": ["STRAIGHT", "FLUSH"],
	"FULL_HOUSE": ["THREE_OF_A_KIND", "PAIR"],
	"TWO_PAIR": ["PAIR"],
}

## 四指 (Four Fingers)：同花 / 顺子 / 同花顺最少只需 4 张牌（见 joker.json）
const FOUR_FINGERS_JOKER := "Four Fingers"
const DEFAULT_RUN_SIZE := 5
const FOUR_FINGERS_RUN_SIZE := 4


# ---------------------------------------------------------------------------
# 牌型分析（静态方法，不依赖 CardManager 实例状态）
# ---------------------------------------------------------------------------

## 分析一组出牌，判定牌型并提取各牌型的计分牌
##
## @param cards 玩家本次打出的牌（通常 1~5 张，来自 selected_cards）
## @return Dictionary，字段说明：
##   - primary_hand: String          能构成的最强牌型
##   - other_contained_hands: Array  除主牌型外，还包含的子牌型列表
##   - hand_scored_cards: Dictionary 每种牌型 -> 参与该牌型计分的 Card 数组
##   - base_chips: int               主牌型基础筹码
##   - base_mult: int                主牌型基础倍率
##
## 示例：打出 AA KK 2 → primary_hand="TWO_PAIR"
##       hand_scored_cards["TWO_PAIR"] 为 4 张对子牌
##       other_contained_hands=["PAIR"]，且 PAIR 的计分牌同样是这 4 张
func evaluate_hand(cards: Array[Card]) -> Dictionary:
	var primary_hand := _detect_best_hand(cards)
	var contained_types := _get_contained_hand_types(primary_hand)
	var hand_scored_cards: Dictionary = {}

	for hand_type in contained_types:
		hand_scored_cards[hand_type] = _get_scoring_cards(cards, hand_type)

	var other_contained: Array[String] = []
	for hand_type in contained_types:
		if hand_type != primary_hand:
			other_contained.append(hand_type)

	var base: Dictionary = HAND_BASE.get(primary_hand, {"chips": 0, "mult": 1})
	return {
		"primary_hand": primary_hand,
		"other_contained_hands": other_contained,
		"hand_scored_cards": hand_scored_cards,
		"base_chips": base.chips,
		"base_mult": base.mult,
	}


## 返回主牌型及其所有子牌型（主牌型始终在列表首位）
func _get_contained_hand_types(primary_hand: String) -> Array[String]:
	var result: Array[String] = [primary_hand]
	if HAND_CONTAINS.has(primary_hand):
		for sub_type in HAND_CONTAINS[primary_hand]:
			if sub_type not in result:
				result.append(sub_type)
	return result


## 从已打出的牌中判定最强牌型
## 同花 / 顺子 / 同花顺默认需 5 张；装备「四指」小丑时降为 4 张
func _detect_best_hand(cards: Array[Card]) -> String:
	if cards.is_empty():
		return "HIGH_CARD"

	# 统计各点数出现次数，如 { "8": 2, "9": 2, "2": 1 } → [2, 2, 1]
	var rank_counts := _count_ranks(cards)
	var count_values: Array[int] = []
	for count: int in rank_counts.values():
		count_values.append(count)
	count_values.sort()
	count_values.reverse()

	if not _find_straight_flush_scoring_cards(cards).is_empty():
		return "STRAIGHT_FLUSH"
	if count_values[0] == 4:
		return "FOUR_OF_A_KIND"
	if count_values.size() >= 2 and count_values[0] == 3 and count_values[1] == 2:
		return "FULL_HOUSE"
	if not _find_flush_scoring_cards(cards).is_empty():
		return "FLUSH"
	if not _find_straight_scoring_cards(cards).is_empty():
		return "STRAIGHT"
	if count_values[0] == 3:
		return "THREE_OF_A_KIND"
	if count_values.size() >= 2 and count_values[0] == 2 and count_values[1] == 2:
		return "TWO_PAIR"
	if count_values[0] == 2:
		return "PAIR"
	return "HIGH_CARD"


## 获取指定牌型下参与计分的牌（Balatro 规则）
## - 高牌：仅最高的一张
## - 对子 / 两对 / 三条 / 四条：仅重复点数的牌
## - 顺子 / 同花 / 同花顺：构成该牌型的牌（四指时可能为 4 张，而非全部出牌）
## - 葫芦：全部出牌均计分
func _get_scoring_cards(cards: Array[Card], hand_type: String) -> Array[Card]:
	var rank_counts := _count_ranks(cards)
	match hand_type:
		"HIGH_CARD":
			return [_get_highest_card(cards)]
		"PAIR":
			var pair_ranks := _find_ranks_with_count(rank_counts, 2)
			return _filter_cards_by_ranks(cards, pair_ranks)
		"TWO_PAIR":
			var pair_ranks := _find_ranks_with_count(rank_counts, 2)
			return _filter_cards_by_ranks(cards, pair_ranks)
		"THREE_OF_A_KIND":
			var triple_rank := _find_rank_with_count(rank_counts, 3)
			return _filter_cards_by_rank(cards, triple_rank)
		"FOUR_OF_A_KIND":
			var quad_rank := _find_rank_with_count(rank_counts, 4)
			return _filter_cards_by_rank(cards, quad_rank)
		"STRAIGHT":
			return _find_straight_scoring_cards(cards)
		"FLUSH":
			return _find_flush_scoring_cards(cards)
		"STRAIGHT_FLUSH":
			return _find_straight_flush_scoring_cards(cards)
		"FULL_HOUSE":
			return cards.duplicate()
		_:
			return []


## 统计每种 rank 出现的次数，返回 { rank_string: count }
func _count_ranks(cards: Array[Card]) -> Dictionary:
	var counts: Dictionary = {}
	for card in cards:
		counts[card.rank] = counts.get(card.rank, 0) + 1
	return counts


## 将 rank 字符串转为可比较的整数值；A 在比大小时视为 14（最大）
func _rank_to_value(rank: String, ace_high: bool = true) -> int:
	var value := int(rank)
	if value == 1 and ace_high:
		return 14
	return value


## 返回点数最大的牌（同点数时取先遇到的）
func _get_highest_card(cards: Array[Card]) -> Card:
	var best := cards[0]
	for i in range(1, cards.size()):
		if _rank_to_value(cards[i].rank) > _rank_to_value(best.rank):
			best = cards[i]
	return best


## 在 rank_counts 中找出现 target_count 次且点数最大的 rank
func _find_rank_with_count(rank_counts: Dictionary, target_count: int) -> String:
	var best_rank := ""
	var best_value := -1
	for rank: String in rank_counts:
		if rank_counts[rank] == target_count:
			var rank_value := _rank_to_value(rank)
			if rank_value > best_value:
				best_value = rank_value
				best_rank = rank
	return best_rank


## 找所有出现 target_count 次的 rank，按点数从大到小排序
func _find_ranks_with_count(rank_counts: Dictionary, target_count: int) -> Array[String]:
	var ranks: Array[String] = []
	for rank: String in rank_counts:
		if rank_counts[rank] == target_count:
			ranks.append(rank)
	ranks.sort_custom(func(a: String, b: String) -> bool:
		return _rank_to_value(a) > _rank_to_value(b)
	)
	return ranks


func _filter_cards_by_rank(cards: Array[Card], rank: String) -> Array[Card]:
	return cards.filter(func(card: Card) -> bool: return card.rank == rank)


func _filter_cards_by_ranks(cards: Array[Card], ranks: Array[String]) -> Array[Card]:
	return cards.filter(func(card: Card) -> bool: return card.rank in ranks)


# ---------------------------------------------------------------------------
# 同花 / 顺子判定（支持「四指」小丑：最少 4 张即可）
# ---------------------------------------------------------------------------

## 是否装备「四指」小丑，同花和顺子最少张数降为 4
func _has_four_fingers() -> bool:
	return JokerManager.has_joker(FOUR_FINGERS_JOKER)


## 当前规则下同花 / 顺子 / 同花顺所需的最少张数
func _get_min_run_size() -> int:
	return FOUR_FINGERS_RUN_SIZE if _has_four_fingers() else DEFAULT_RUN_SIZE


## 找出构成同花的计分牌；出牌数大于最少张数时取同花色最多的那组
func _find_flush_scoring_cards(cards: Array[Card]) -> Array[Card]:
	var min_size := _get_min_run_size()
	if cards.size() < min_size:
		return []

	var suits := ["s", "h", "c", "d"]
	var best_group: Array[Card] = []
	for suit in suits:
		var group := _cards_matching_suit(cards, suit)
		if group.size() > best_group.size():
			best_group = group

	if best_group.size() >= min_size:
		return best_group
	return []


## 找出构成顺子的计分牌；优先取张数最多的连续组合
func _find_straight_scoring_cards(cards: Array[Card]) -> Array[Card]:
	var min_size := _get_min_run_size()
	if cards.size() < min_size:
		return []

	for size in range(cards.size(), min_size - 1, -1):
		for subset: Array in _get_subsets_of_size(cards, size):
			if _is_straight_subset(subset):
				return subset
	return []


## 找出同时满足同花与顺子的计分牌；优先取张数最多的组合
func _find_straight_flush_scoring_cards(cards: Array[Card]) -> Array[Card]:
	var min_size := _get_min_run_size()
	if cards.size() < min_size:
		return []

	for size in range(cards.size(), min_size - 1, -1):
		for subset: Array in _get_subsets_of_size(cards, size):
			if _is_flush_subset(subset) and _is_straight_subset(subset):
				return subset
	return []


## 万能牌视为指定花色；返回该花色（含万能牌）下的所有牌
func _cards_matching_suit(cards: Array[Card], suit: String) -> Array[Card]:
	return cards.filter(func(card: Card) -> bool:
		return card.strenthType == Card.StrenthType.Wild or card.suit == suit
	)


## 判定一组牌是否同花（万能牌可匹配任意花色）
func _is_flush_subset(cards: Array[Card]) -> bool:
	if cards.is_empty():
		return false
	var non_wild := cards.filter(func(card: Card) -> bool:
		return card.strenthType != Card.StrenthType.Wild
	)
	if non_wild.is_empty():
		return true
	var suit: String = non_wild[0].suit
	return non_wild.all(func(card: Card) -> bool: return card.suit == suit)


## 判定一组牌是否顺子（点数互异且连续，支持 A 当 1）
func _is_straight_subset(cards: Array[Card]) -> bool:
	var values: Array[int] = []
	for card in cards:
		values.append(_rank_to_value(card.rank))
	return _values_are_straight(values)


## 检查一组点数是否能构成顺子
func _values_are_straight(values: Array[int]) -> bool:
	if values.is_empty():
		return false

	var unique: Array[int] = []
	for value in values:
		if value in unique:
			return false
		unique.append(value)
	unique.sort()

	if _is_consecutive_values(unique):
		return true

	# A 当 1 的小顺（如 A-2-3-4 或 A-2-3-4-5）
	if 14 in unique:
		var low_values: Array[int] = []
		for value in unique:
			low_values.append(1 if value == 14 else value)
		low_values.sort()
		return _is_consecutive_values(low_values)
	return false


func _is_consecutive_values(values: Array[int]) -> bool:
	if values.size() <= 1:
		return values.size() == 1
	for i in range(1, values.size()):
		if values[i] != values[i - 1] + 1:
			return false
	return true


## 枚举 cards 中所有恰好为 size 张的子集（最多 5 张牌，位掩码即可）
func _get_subsets_of_size(cards: Array[Card], size: int) -> Array:
	var result: Array = []
	var card_count := cards.size()
	if size < 1 or size > card_count:
		return result

	var total_masks := 1 << card_count
	for mask in range(total_masks):
		if _popcount(mask) != size:
			continue
		var subset: Array[Card] = []
		for i in range(card_count):
			if mask & (1 << i):
				subset.append(cards[i])
		result.append(subset)
	return result


func _popcount(value: int) -> int:
	var count := 0
	while value > 0:
		count += value & 1
		value >>= 1
	return count
