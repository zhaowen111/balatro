class_name TextureUtils
extends RefCounted

static var _texture_cache: Dictionary = {}
static func load_card_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]
	var texture = load(path) as Texture2D
	if texture == null:
		push_warning("无法加载卡牌纹理: %s" % path)
		return null
	_texture_cache[path] = texture
	return texture