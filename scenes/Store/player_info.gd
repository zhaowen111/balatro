extends Node2D

const StatBinderScript = preload("res://scripts/utils/stat_binder.gd")

@export var titleAnimation: AnimatedSprite2D
@export var allScoreLabel: Label
@export var subScoreLabel: Label
@export var magLabel: Label
@export var playcardLabel: Label
@export var discardLabel: Label
@export var coinLabel: Label
@export var anteLabel: Label
@export var maxAnteLabel: Label
@export var turnsLabel: Label

var _stat_binder = StatBinderScript.new()

func _ready() -> void:
	for binding in _get_stat_bindings():
		_stat_binder.bind(
			MyPlayerAssets,
			binding["label"],
			binding["property"],
			binding["signal"]
		)
	titleAnimation.play()

func _exit_tree() -> void:
	_stat_binder.unbind_all()

func _get_stat_bindings() -> Array[Dictionary]:
	return [
		{"property": &"allScore", "signal": &"allScoreChange", "label": allScoreLabel},
		{"property": &"subScore", "signal": &"subScoreChange", "label": subScoreLabel},
		{"property": &"mag", "signal": &"magChange", "label": magLabel},
		{"property": &"playCount", "signal": &"playCountChange", "label": playcardLabel},
		{"property": &"discardCount", "signal": &"discardCountChange", "label": discardLabel},
		{"property": &"coin", "signal": &"coinChange", "label": coinLabel},
		{"property": &"ante", "signal": &"anteChange", "label": anteLabel},
		{"property": &"maxAnte", "signal": &"maxAnteChange", "label": maxAnteLabel},
		{"property": &"turns", "signal": &"turnsChange", "label": turnsLabel},
	]

func show_match_info() -> void:
	pass

func show_options() -> void:
	pass
