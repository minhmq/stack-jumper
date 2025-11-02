extends RefCounted
class_name ObjectPool

## Generic object pool for reusing nodes (Platforms, Coins, etc.)
## Reduces allocations and improves performance

var _pool: Array[Node] = []
var _scene: PackedScene
var _parent: Node

func _init(scene: PackedScene, parent: Node, initial_size: int = 5) -> void:
	_scene = scene
	_parent = parent
	
	# Pre-populate pool
	for i in range(initial_size):
		var instance = _scene.instantiate()
		instance.set_meta("pooled", true)
		_pool.append(instance)

func acquire() -> Node:
	var instance: Node
	if _pool.is_empty():
		instance = _scene.instantiate()
		instance.set_meta("pooled", true)
	else:
		instance = _pool.pop_back()
	
	if instance.get_parent():
		instance.get_parent().remove_child(instance)
	
	_parent.add_child(instance)
	instance.set_meta("pooled", true)
	return instance

func release(node: Node) -> void:
	if not node.has_meta("pooled"):
		return
	
	if node.get_parent():
		node.get_parent().remove_child(node)
	
	# Reset node state
	if node.has_method("reset"):
		node.reset()
	
	_pool.append(node)

func clear() -> void:
	for node in _pool:
		if is_instance_valid(node):
			node.queue_free()
	_pool.clear()

