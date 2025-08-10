extends Triggerable

func trigger():
	var new_bot = load("res://npc/enemy/totembot/totembot.tscn").instantiate()

	get_tree().root.add_child(new_bot)
	new_bot.global_position = Vector3(randf_range(-10.0, 10.0), 15.0, randf_range(-10.0, 10.0))
