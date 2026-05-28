# CardResource.gd
extends Resource
class_name Card

@export var texture: Texture2D      # 牌的纹理
@export var rank: String            # 点数 (A, 2, 3...K)
@export var suit: String            # 花色 (spade, heart, club, diamond)
@export var chip_value: int         # 筹码值
