class_name Player_Insertable_Pouch extends Node3D

@export var INSERTABLE:PackedScene;
@export var MAX_EXISTING:int = 2;


var current_instances:int = 0;
var instances:Array[Gun_Insertable];

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	#Logic to decide if to summon a new instance
	for i in range(0, MAX_EXISTING):
		if(len(instances) > i):
			if(instances[i] == null):
				instances.pop_at(i)
				current_instances -= 1
			if(i == current_instances-1):
				if instances[i].has_been_focused == true and current_instances < MAX_EXISTING:
					summon_new_after_delay(0.3)
					
	if(current_instances == 0):
		summon_new()



func summon_new() -> void:
	summoning_in_progress = false;
	
	var new_instance:Gun_Insertable = INSERTABLE.instantiate();
	new_instance.visible = true;
	new_instance.process_mode = Node.PROCESS_MODE_INHERIT
	get_parent().add_child(new_instance)

	new_instance.global_position = global_position
	new_instance.MODEL.global_basis = global_basis
	
	instances.push_back(new_instance)

	current_instances += 1


var summoning_in_progress:bool = false;
func summon_new_after_delay(time:float = 0.5, forced:bool = false):
	if(!forced and summoning_in_progress):
		return
	var timer = Timer.new()
	timer.timeout.connect(timer.queue_free)
	timer.timeout.connect(self.summon_new)
	timer.wait_time = time
	add_child(timer)
	timer.start()
	summoning_in_progress = true;
