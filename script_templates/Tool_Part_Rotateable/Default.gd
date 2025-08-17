extends Gun_Part_Rotateable




##Ready
func _ready():
	super._ready();


func _process(delta:float) -> void:
	super._process(delta);

func _physics_process(delta:float) -> void:
	super._physics_process(delta);



func hit_zero_angle(speed:float) -> void:
	pass
func hit_max_angle(speed:float) -> void:
	pass
