## 回合管理器：将游戏流程事件转发给 TagManager / JokerManager
extends Node

## 回合开始（同时触发 ON_NEXT_ROUND_START 与 ON_ROUND_START）
func start_round() -> void:
	TagManager.on_round_start()

func end_round() -> void:
	TagManager.on_round_end()

## Boss 盲注被击败
func on_boss_defeated() -> void:
	TagManager.on_boss_defeated()

## 跳过盲注
func on_blind_skipped() -> void:
	TagManager.on_blind_skipped()

## 打开商店
func on_shop_open() -> void:
	TagManager.on_shop_open()

## 计分入口：传入牌型、计分牌列表，返回累计后的 ScoringContext
func score_hand(hand_type: String, scored_cards: Array, discards_left: int = 0) -> ScoringContext:
	return JokerManager.score_hand(hand_type, scored_cards, discards_left)
