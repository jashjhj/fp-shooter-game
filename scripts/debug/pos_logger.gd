class_name Position_Logger extends Node3D

@export_group("Is logging..", "IS_LOGGING")
@export var IS_LOGGING_POSITION:bool = true

func _process(delta: float) -> void:
	if(IS_LOGGING_POSITION):
		DebugDraw3D.draw_text(global_position, str(global_position))

func _physics_process(delta: float) -> void:
	if(IS_LOGGING_POSITION):
		print(global_position)
