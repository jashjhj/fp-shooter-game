extends Triggerable

func trigger():
	var new_bot = load("res://npc/enemy/totembot/totembot.tscn").instantiate()

	new_bot.position = Vector3(randf_range(-10.0, 10.0), 15.0, randf_range(-10.0, 10.0)) # this gives errors but its kind of okay
	add_child(new_bot)
	
	#get_tree().root.add_child(new_bot)
