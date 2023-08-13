class_name CacheProperties
extends Node

@export var properties: Array[String]
@export var node_path: NodePath
@export var debug = false

var logger = Logger.new("CacheProperties")

func _ready():
	add_to_group(CacheManager.PERSIST_GROUP)

func _get_node():
	var node = null
	if node_path != null and node_path != NodePath(""):
		node = get_node(node_path)
	if node == null:
		node = get_parent()
	
	return node

func save_data():
	var data = {}
	for prop in properties:
		data[prop] = _get_node().get(prop)

	if debug:
		logger.debug("Save for %s: %s" % [get_tree().current_scene.get_path_to(get_parent()), str(data)])
	return data

func _enter_tree():
	var data = CacheManager.get_data_for(self)
	if data:
		load_data(data)

func load_data(data: Dictionary):
	if debug:
		logger.debug("Load for %s: %s" % [get_tree().current_scene.get_path_to(get_parent()), str(data)])
	for prop in data:
		_get_node().set(prop, data[prop])
