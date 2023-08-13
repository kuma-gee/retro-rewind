class_name CacheProperties
extends Node

@export var properties: Array[String]
@export var node_path: NodePath

var logger = Logger.new("CacheProperties")


func _ready():
	add_to_group(CacheManager.PERSIST_GROUP)


func save_data():
	var data = {}
	for prop in properties:
		data[prop] = get_parent().get(prop)

	logger.debug("Save for %s: %s" % [get_tree().current_scene.get_path_to(get_parent()), str(data)])
	return data

func _enter_tree():
	var data = CacheManager.get_data_for(self)
	if data:
		load_data(data)

func load_data(data: Dictionary):
	logger.debug("Load for %s: %s" % [get_tree().current_scene.get_path_to(get_parent()), str(data)])
	for prop in data:
		get_parent().set(prop, data[prop])
