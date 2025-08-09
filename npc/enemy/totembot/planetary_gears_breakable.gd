class_name Planetary_Gears_Breakable extends Planetary_Gears

@export var PLANET_HP_COMPONENT:Hit_HP_Tracker;

var working_gears:int:
	set(v):
		working_gears = v; # MIN to nto increase speed if tis altered otherwise
		ROTATION_MAX_SPEED = min(ROTATION_MAX_SPEED, initial_rot_speed * float(working_gears) / float(GEARS_NUM))

var initial_rot_speed:float;

var planet_hp_path:NodePath;

func _ready() -> void:
	super()
	initial_rot_speed = ROTATION_MAX_SPEED
	working_gears = GEARS_NUM
	
	
	assert(PLANET_HP_COMPONENT != null, "No planet HP component set.")
	planet_hp_path = GEAR.get_path_to(PLANET_HP_COMPONENT)
	
	for gear in GEARS:
		get_node(str(gear.get_path()) + "/" + str(planet_hp_path)).on_hp_becomes_negative.connect(lose_one_gear)


func lose_one_gear():
	for i in range(0, len(GEARS)): # removes from array. ensures each gear can only be removed once.
		if !get_node(str(GEARS[i].get_path()) + "/" + str(planet_hp_path)).is_hp_positive:
			GEARS.remove_at(i)
			working_gears -= 1;
			return
