class_name AddHandCount
extends Effect

func triggerEffect(context: Dictionary = {}) -> void:
	MyPlayerAssets.handCount += params[0]
	print(context)
