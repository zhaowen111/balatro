class_name Blind
extends RefCounted
enum BlindType {
	small=1,
	large=2,
	boss=3
}

var score:int
var award:int
var blindType:BlindType
var tag:BlindTag
var texture:AtlasTexture


func skip():
	#TODO:触发标签
	#TODO:跳到下一个盲注
	
func select():
	#TODO:回合数+1
	#TODO:开始一局游戏
	#目前先直接跳到下一局游戏
