class_name SelectBlind
extends Node
static var blindScoresDeck: Array[int] = [0, 300, 800, 2000, 5000, 11000, 20000, 35000, 50000, 110000]
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
static func levelUp():
	curAnte = MyPlayerAssets.ante
	var _blinds = createThreeBlind()
	createAndAddNode(_blinds[0], _blinds[1], _blinds[2])
	MyPlayerAssets.currentBlindCount += 1
static func createThreeBlind():
	var index = MyPlayerAssets.currentBlindCount + 1
	var smallBlind = Blind.new(index, Blind.BlindType.small, TagManager.tag_definitions[18])
	blinds[index] = smallBlind
	index += 1
	
	var largeBlind = Blind.new(index, Blind.BlindType.large, TagManager.pick_random_tag())
	blinds[index] = largeBlind
	index += 1
	
	
	var bossBlind = Blind.new(index, Blind.BlindType.boss, {})
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
	smallNode.get_node('tag').mouse_entered.connect(smallNode._on_tag_mouse_entered.bind())
	smallNode.get_node('tag').mouse_exited.connect(smallNode._on_tag_mouse_exited.bind())
	smallNode.position = Vector2(400, 200)
	smallNode.get_node('title').text = "小盲注"
	smallNode.get_node('score').text = str(smallBlind.score)
	smallNode.get_node('award').text = str(smallBlind.award)
	smallNode.get_node('tag').text = smallBlind.tag['zh_name']
	smallNode.setup(smallBlind)
	container.add_child(smallNode)
	
	var largeNode = blindNode.instantiate()
	largeNode.get_node('select').pressed.connect(largeNode.select.bind())
	largeNode.get_node('skip').pressed.connect(largeNode.skip.bind())
	largeNode.get_node('tag').mouse_entered.connect(largeNode._on_tag_mouse_entered.bind())
	largeNode.get_node('tag').mouse_exited.connect(largeNode._on_tag_mouse_exited.bind())
	largeNode.position = Vector2(600, 200)
	largeNode.get_node('title').text = "大盲注"
	largeNode.get_node('score').text = str(largeBlind.score)
	largeNode.get_node('award').text = str(largeBlind.award)
	largeNode.get_node('tag').text = largeBlind.tag['zh_name']
	largeNode.setup(largeBlind)
	container.add_child(largeNode)
	
	var bossNode = blindNode.instantiate()
	bossNode.get_node('select').pressed.connect(bossNode.select.bind())
	bossNode.position = Vector2(800, 200)
	bossNode.get_node('title').text = "boss盲注"
	bossNode.get_node('score').text = str(bossBlind.score)
	bossNode.get_node('award').text = str(bossBlind.award)
	bossNode.get_node('tag').visible = false
	bossNode.get_node('blindDesc').text = str(bossBlind.mangzhu['description'])

	bossNode.setup(bossBlind)
	container.add_child(bossNode)
