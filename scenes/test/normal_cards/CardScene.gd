# CardScene.gd
extends Node2D

const CARD_WIDTH = 142
const CARD_HEIGHT = 190

@onready var card_texture: TextureRect = $Panel/CardTexture
@export var mark2d: Marker2D

func setup(card: Card) -> void:
	if not card_texture:
		return
	card_texture.texture = card.texture
	card_texture.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_texture.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
