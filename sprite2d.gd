extends Sprite2D

var ress = preload("res://MyResource.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(ress.a)
	ress.a = 10
	print(load("res://MyResource.tres").a)

var rotation_y: float = 0.0  # 虚拟 Y 轴旋转角度（度）

func _process(delta):
	# 更新虚拟 Y 轴旋转
	rotation_y += 90.0 * delta
	
	# 模拟 Y 轴旋转：X 轴缩放随角度变化
	var angle_rad = deg_to_rad(rotation_y)
	scale.x = abs(cos(angle_rad))  # 正面时 scale.x = 1，侧面时 = 0
	
	# 可选：添加倾斜增加立体感
	skew = sin(angle_rad) * deg_to_rad(15.0)


func _on_button_pressed() -> void:
	skew+=deg_to_rad(15)
