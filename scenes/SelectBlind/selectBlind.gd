class_name SelectBlind
extends Node
static var blindScoresDeck: Array[int] = [0, 300, 450, 600, 1000, 1500, 2250, 3000, 4500, 6000, 10000, 15000, 22500, 30000, 45000, 60000, 100000, 150000, 225000, 300000, 450000, 600000, 1000000, 1500000, 2250000]
static var blindNode = preload("res://scenes/SelectBlind/Blind.tscn")
static var blinds: Array = []
static var curDeck: Array[Blind] = []
static var container: Node = null
static var curNode = null
static var curAnte = 0
func _init():
	if (blinds.size() == 0):
		blinds.resize(100)

func _ready() -> void:
	container = $HBoxContainer
	if (MyPlayerAssets.ante > curAnte):
		levelUp()
	else:
		createAndAddNode(curDeck[0], curDeck[1], curDeck[2])
	setBlindState(MyPlayerAssets.currentBlindCount)
static func levelUp():
	curAnte = MyPlayerAssets.ante
	var _blinds = createThreeBlind()
	createAndAddNode(_blinds[0], _blinds[1], _blinds[2])
	MyPlayerAssets.currentBlindCount += 1
static func createThreeBlind():
	var index = MyPlayerAssets.currentBlindCount + 1
	var smallBlind = Blind.new(index, blindScoresDeck[index], 3, Blind.BlindType.small, BlindTag.TAGS.pick_random(), null)
	blinds[index] = smallBlind
	index += 1
	
	var largeBlind = Blind.new(index, blindScoresDeck[index], 4, Blind.BlindType.large, BlindTag.TAGS.pick_random(), null)
	blinds[index] = largeBlind
	index += 1
	
	
	var bossBlind = Blind.new(index, blindScoresDeck[index], 5, Blind.BlindType.boss, BlindTag.TAGS.pick_random(), null)
	blinds[index] = bossBlind

	curDeck.resize(3)
	curDeck[0] = smallBlind
	curDeck[1] = largeBlind
	curDeck[2] = bossBlind

	return [smallBlind, largeBlind, bossBlind]
static func createAndAddNode(smallBlind: Blind, largeBlind: Blind, bossBlind: Blind):
	var smallNode = blindNode.instantiate()
	smallNode.get_node('select').pressed.connect(smallNode.select.bind())
	smallNode.get_node('skip').pressed.connect(smallNode.skip.bind())
	smallNode.position = Vector2(400, 200)
	smallNode.get_node('title').text = "小盲注"
	smallNode.get_node('score').text = str(smallBlind.score)
	smallNode.get_node('award').text = str(smallBlind.award)
	container.add_child(smallNode)
	smallBlind.node = smallNode
	var largeNode = blindNode.instantiate()
	largeNode.get_node('select').pressed.connect(largeNode.select.bind())
	largeNode.get_node('skip').pressed.connect(largeNode.skip.bind())
	largeNode.position = Vector2(600, 200)
	largeNode.get_node('title').text = "大盲注"
	largeNode.get_node('score').text = str(largeBlind.score)
	largeNode.get_node('award').text = str(largeBlind.award)
	container.add_child(largeNode)
	largeBlind.node = largeNode
	var bossNode = blindNode.instantiate()
	bossNode.get_node('select').pressed.connect(bossNode.select.bind())
	bossNode.get_node('skip').pressed.connect(bossNode.skip.bind())
	bossNode.position = Vector2(800, 200)
	bossNode.get_node('title').text = "boss盲注"
	bossNode.get_node('score').text = str(bossBlind.score)
	bossNode.get_node('award').text = str(bossBlind.award)
	container.add_child(bossNode)
	bossBlind.node = bossNode

func setBlindState(index):
	if curNode:
		curNode.get_node('select').visible = false
		curNode.get_node('skip').visible = false
	var blind = blinds[index]
	if blind:
		if blind.blindType != Blind.BlindType.boss:
			blind.node.get_node('skip').visible = true
		blind.node.get_node('select').visible = true
