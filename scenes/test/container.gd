extends Node2D

@export var card_scene: PackedScene  # 卡片场景
@export var card_width: float = 100.0  # 每张卡片的宽度
@export var horizontal_spacing: float = 2.0/3.0  # 水平间距比例（相对于卡片宽度）
@export var rotation_angle: float = 5.0  # 每层旋转角度（度）
@export var arc_radius: float = 500.0  # 圆弧半径
@export var flatten_factor: float = 0.3  # 压扁系数（值越小越平）

var hand_cards: Array = []  # 存储当前手牌节点


# 添加手牌（批量或单张）
func add_card(card_data = null):
	var new_card = card_scene.instantiate()
	add_child(new_card)
	hand_cards.append(new_card)
	update_card_positions()
	return new_card


func remove_card(card_node):
	var index = hand_cards.find(card_node)
	if index != -1:
		hand_cards.remove_at(index)
		card_node.queue_free()
		update_card_positions()
@export var radius: float = 300.0  # 公转半径
func update_card_positions():
	var card_count = hand_cards.size()
	if card_count == 0:
		return
	
	# 计算中位牌索引
	var middle_index = (card_count - 1) / 2
	
	# 计算每张卡片的水平偏移（保持原逻辑）
	var actual_spacing = card_width * horizontal_spacing
	var total_width = actual_spacing * card_count
	var start_x = -total_width / 2.0
	
	for i in range(card_count):
		var card = hand_cards[i]
		var offset = i - middle_index
		
		# 原逻辑：线性X位置
		var linear_x = start_x + i * actual_spacing
		
		# 将线性X位置映射到角度（例如：X范围映射到 -45° 到 45°）
		var max_angle = 45.0
		var angle_deg = (linear_x / (total_width / 2)) * max_angle if total_width > 0 else 0
		angle_deg = clamp(angle_deg, -max_angle, max_angle)
		
		# 转换为弧度
		var angle_rad = deg_to_rad(angle_deg)
		
		# 计算围绕父节点的位置（关键点！）
		var x_pos = radius * sin(angle_rad)
		var y_pos = radius * (1 - cos(angle_rad))  # 让卡片在下方排列
		
		# 应用位置
		card.position = Vector2(x_pos, y_pos)
		
		# 卡片自身旋转（根据原逻辑）
		card.rotation_degrees = -offset * rotation_angle
# 可选：支持动态调整卡片宽度（例如响应窗口大小变化）
func set_card_width(new_width: float):
	card_width = new_width
	update_card_positions()
