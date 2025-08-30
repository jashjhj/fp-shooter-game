extends Control

var is_menu_enabled:bool = false:
	set(v):
		if(v == is_menu_enabled): return
		is_menu_enabled = v
		if(is_menu_enabled):
			enable_menu()
		else:
			disable_menu()




func _ready() -> void:
	disable_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		is_menu_enabled = !is_menu_enabled

func enable_menu():
	get_tree().paused = true
	get_child(0).visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func disable_menu():
	get_tree().paused = false
	get_child(0).visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_quit_pressed() -> void:
	get_tree().quit()
