extends Control


@export var is_debug_menu_visible = false;


func _ready() -> void:
	$"Debug Menu".visible = is_debug_menu_visible



func _on_toggle_visibility_button_up() -> void:
	is_debug_menu_visible = !is_debug_menu_visible
	$"Debug Menu".visible = is_debug_menu_visible


func _on_timescale_slider_drag_ended(value_changed: bool) -> void:
	var new_timescale:float = $"Debug Menu/VBoxContainer/Timescale Slider".value
	Engine.time_scale = float(new_timescale / 120.0)
	Engine.physics_ticks_per_second = new_timescale
