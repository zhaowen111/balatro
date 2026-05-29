extends Node
@export var allScore = 0
@export var subScore = 0
@export var mag = 0 #倍率
@export var playCount = 0
@export var discardCount = 0
@export var coin = 0

signal  anteChange(newAnte:int)
@export var ante = 1: #底注
	set(val):
		anteChange.emit(val)
@export var maxAnte = 8 #底注上限
@export var turns = 0 #回合数




@export var test1:Array[int] = []
@export var test2:Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func testPrint():
	print(111)
