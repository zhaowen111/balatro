class_name StatBinder
extends RefCounted

var _connections: Array[Dictionary] = []

func bind(source: Node, label: Label, property: StringName, signal_name: StringName) -> void:
	if label == null:
		push_warning("StatBinder: label 为空，跳过绑定 %s" % property)
		return
	label.text = str(source.get(property))
	# RefCounted 方法 bind 后参数顺序与信号不匹配，用 lambda 捕获 label
	var callable := func(value: Variant) -> void:
		label.text = str(value)
	var change_signal: Signal = source.get(signal_name)
	change_signal.connect(callable)
	_connections.append({
		"source": source,
		"signal_name": signal_name,
		"callable": callable,
	})

func unbind_all() -> void:
	for conn in _connections:
		var source: Node = conn["source"]
		var signal_name: StringName = conn["signal_name"]
		var callable: Callable = conn["callable"]
		if source.is_connected(signal_name, callable):
			source.disconnect(signal_name, callable)
	_connections.clear()
