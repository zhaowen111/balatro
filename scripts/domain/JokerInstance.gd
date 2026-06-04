class_name JokerInstance
extends RefCounted
var en_name: String ## 英文名（唯一标识）
var definition: Dictionary ## 来自 joker.json 的完整定义
var state: Dictionary = {} ## 运行时状态（可扩展）
