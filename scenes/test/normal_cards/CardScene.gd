# CardScene.gd
extends Node2D

@onready var card_texture = $Panel/CardTexture
@export var mark2d:Marker2D
func setup(card: Card):
	if(not card_texture):
		return
	card_texture.texture = card.texture
