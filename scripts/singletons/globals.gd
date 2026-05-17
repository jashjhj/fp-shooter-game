extends Node

var PLAYER:Player;
var RUBBISH_COLLECTOR:RubbishCollector;

func _ready() -> void:
	get_tree().current_scene.add_child(RubbishCollector.new());
