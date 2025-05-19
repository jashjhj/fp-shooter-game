class_name Gun_Part_Slideable extends Gun_Part_Interactive



var start_focus_mouse_pos:Vector3;
var previous_focus_mouse_pos:Vector3;


##Ready
func _ready():
	super._ready();

func _process(delta:float) -> void:
	super._process(delta);


#Enable and disable being clicked on
func enable_focus():
	pass

func disable_focus():
	pass
