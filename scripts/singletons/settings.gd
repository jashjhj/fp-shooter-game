extends Node

var Mouse_LookSensitivity := 1.0;
var Mouse_AimSensitivity := 0.5;
var Mouse_InteractSensitivity := 1.0;

var Max_Rubbish := 300;


var config_loader:Config_File_Handler
func _ready() -> void:
	config_loader = Config_File_Handler.new();
	config_loader.init()
	
	print_debug("Settings Loaded")

func value_updated() -> void:
	config_loader.save_settings()
