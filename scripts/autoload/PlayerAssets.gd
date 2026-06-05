## 玩家资产与局内状态单例（Autoload: MyPlayerAssets）
##
## 保存当前一局（Run）中玩家的核心数值与进度，供出牌、选盲注、商店、
## UI 等系统读写。属性均通过 setter 发出变更信号，便于界面自动刷新。
##
## 数值大致对应 Balatro 概念：
## - allScore / subScore / mag → 本盲注累计得分与单次出牌分解
## - playCount / discardCount → 每回合出牌 / 弃牌次数
## - coin → 金钱；ante → 底注等级（难度）
## - currentBlindCount → 当前盲注在 blinds 数组中的索引
extends Node

# ---------------------------------------------------------------------------
# 计分相关
# ---------------------------------------------------------------------------

## 本盲注内已累计的总得分（筹码 × 倍率累加后的结果）。
## 达到当前 Blind.score 即视为通过该盲注；通过后会在 turn.gd 中清零。
signal allScoreChange(newAllScore: int)
@export var allScore = 0:
	set(val):
		allScoreChange.emit(val)
		allScore = val

## 单次出牌的基础筹码部分（不含倍率），主要用于 PlayerInfo UI 展示。
signal subScoreChange(newSubScore: int)
@export var subScore = 0:
	set(val):
		subScoreChange.emit(val)
		subScore = val

## 单次出牌的倍率部分，主要用于 PlayerInfo UI 展示。
signal magChange(newMag: int)
@export var mag = 0:
	set(val):
		magChange.emit(val)
		mag = val

# ---------------------------------------------------------------------------
# 回合行动次数
# ---------------------------------------------------------------------------

## 本回合剩余出牌次数；每次 play_card 消耗 1，归零且未达标则判负。
signal playCountChange(newPlayCount: int)
@export var playCount = 3:
	set(val):
		playCountChange.emit(val)
		playCount = val

## 本回合剩余弃牌次数；每次 discard_card 消耗 1。
signal discardCountChange(newDiscardCount: int)
@export var discardCount = 3:
	set(val):
		discardCountChange.emit(val)
		discardCount = val

# ---------------------------------------------------------------------------
# 经济与 Run 进度
# ---------------------------------------------------------------------------

## 玩家持有的金钱（$），用于商店购买；击败盲注、小丑效果等可增减。
signal coinChange(newCoin: int)
@export var coin = 0:
	set(val):
		coinChange.emit(val)
		coin = val

## 当前底注等级（Ante），影响盲注目标分数等难度参数；击败 Boss 盲注后 +1。
signal anteChange(newAnte: int)
@export var ante = 1:
	set(val):
		anteChange.emit(val)
		ante = val

## 本局允许的最高底注等级，达到后通常视为通关或进入终局。
signal maxAnteChange(newMaxAnte: int)
@export var maxAnte = 8:
	set(val):
		maxAnteChange.emit(val)
		maxAnte = val

## 已进行的回合总数（每进入一次出牌阶段 +1），用于统计或条件判定。
signal turnsChange(newTurns: int)
@export var turns = 0:
	set(val):
		turnsChange.emit(val)
		turns = val

## 当前盲注在 SelectBlind.blinds 数组中的索引。
## 小盲 → 大盲 → Boss 依次递增；选盲注界面与 turn 流程均依赖此索引。
signal curBlindCountChange
@export var currentBlindCount = 0:
	set(val):
		curBlindCountChange.emit(val)
		currentBlindCount = val

# ---------------------------------------------------------------------------
# 局内容量与槽位上限（可被小丑 PASSIVE_STAT 等效果修改）
# ---------------------------------------------------------------------------

## 手牌上限；发牌时 deal_cards 以此为准，小丑如 Juggler 可增减。
signal maxHandCountChange(val: int)
@export var maxHandCount = 8:
	set(val):
		maxHandCountChange.emit(val)
		maxHandCount = val

## 消耗品槽位数量（塔罗 / 星球 / 幻灵等），上限由游戏进度或效果决定。
signal consumedCardCountChange(newConsumedCardCount: int)
@export var consumedCardCount = 0:
	set(val):
		consumedCardCountChange.emit(val)
		consumedCardCount = val

## 小丑牌槽位上限；负片版小丑等效果可突破默认 5 格。
signal maxJokerCountChange(val: int)
@export var maxJokerCount = 5:
	set(val):
		maxJokerCountChange.emit(val)
		maxJokerCount = val
		
signal maxSellCardCountChange(val: int)
@export var maxSellCardCount: int = 3
	set(val):
		maxSellCardCountChange.emit(val)
		maxSellCardCount = val

# ---------------------------------------------------------------------------
# 待生效效果与当前盲注引用
# ---------------------------------------------------------------------------

## 按 effect.id 分组的待执行效果队列。
## 选盲注时点击 BlindTag 会将 Effect 暂存于此，在后续时机统一结算。
var willEffectDict: Dictionary[int, Array] = {}


## 将一条待生效效果加入队列；同一 id 下可叠加多条。
func addWillEffect(effect: Effect) -> void:
	if willEffectDict.has(effect.id):
		willEffectDict[effect.id].append(effect)
	else:
		willEffectDict[effect.id] = [effect]


## 当前正在挑战的 Blind 实例；选盲注确认后由 currentBlindChange 赋值。
var curBlind: Blind = null


func _ready() -> void:
	pass


## 根据 blinds 数组索引切换当前盲注，并同步 SelectBlind 的场景节点引用。
## @param index: SelectBlind.blinds 中的下标
func currentBlindChange(index: int) -> void:
	var blind: Blind = SelectBlind.blinds[index]
	if blind:
		MyPlayerAssets.curBlind = blind
		SelectBlind.curNode = blind.node
