class_name utils
extends RefCounted
# 方法1：遍历查找（适合小规模数据）
static func weighted_random(items: Array, weights: Array):
    var total = 0.0
    for w in weights:
        total += w
    
    var r = randf() * total
    var acc = 0.0
    
    for i in range(items.size()):
        acc += weights[i]
        if r <= acc:
            return items[i]
    
    return items[-1] # fallback
