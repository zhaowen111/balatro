class_name SellCard
extends RefCounted

enum SELLCardType {
	GAME,
	JOKER,
	STAR,
	TALUO,
	SPECTRAL
}

var price: int
var description: String
var en_name: String
var zh_name: String
var type: SELLCardType = SELLCardType.GAME

func _init(card: Dictionary, _type: SELLCardType) -> void:
	price = card.get("price", 0)
	description = card.get("description", "")
	en_name = card.get("en_name", "")
	zh_name = card.get("zh_name", "")
	type = _type