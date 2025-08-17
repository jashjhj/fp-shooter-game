class_name Tool_Part_Insertable_Slot extends Tool_Part
##Magazine/Bullet/clip etc.


@export var INSERTION_PLANE_NORMAL:Vector3 = Vector3.LEFT;
@export var INSERTION_LENGTH:float = 0.1;

@export var INSERTION_ENTRY_AREA:Area3D;

@export var INSERTION_VECTOR:Vector3 = Vector3(0, 0, -1);
@export var FLIP_INSERTION:bool = false;
#@export var OFFSET_NOT_IN_ENTRY:float = 0.02;

#@export var HOUSED_TOLERANCE:float = 0.001

@export var PULL_OBJECT_IN_FACTOR:float = 1;
#@export_range(0, 90, 0.1, "radians_as_degrees") var SLOT_ANGLE_TOLERANCE:float = PI/12

@export_group("Flags")
@export_flags("1","2","4","8","16","32","64") var INSERTION_ACCEPTANCE:int = 1;

var is_locked:bool:
	set(value):
		is_locked = value;
		if(is_locked): # Locks/unlocks the slot.
			INSERTION_ENTRY_AREA.process_mode = Node.PROCESS_MODE_DISABLED
			if(housed_insertable != null):
				housed_insertable.is_focusable = false;
		else:
			INSERTION_ENTRY_AREA.process_mode = Node.PROCESS_MODE_INHERIT
			if(housed_insertable != null):
				housed_insertable.is_focusable = true;

var is_housed:bool = false;
var insertion:float = 0;
var housed_insertable:Tool_Part_Insertable;


const INSERTION_LAYER = 262144 # 2^18 = layer 19


func _ready() -> void:
	assert(INSERTION_ENTRY_AREA != null, "No insertion entry area set.")
	#assert(INSERTION_PATH != null, "No insertion path node set.")
	INSERTION_VECTOR = INSERTION_VECTOR.normalized()
	INSERTION_ENTRY_AREA.collision_layer = INSERTION_LAYER;
	

func _process(delta: float) -> void:
	super._process(delta);
	optional_extras()


## OPTIONAL EXTRAS

@export_group("Optional Extras")
@export var IMPOSED_LIMITS_ROTATEABLES:Array[Gun_Action_Rotateable_Impose_Limit];
@export var WHEN_WITHIN_LIMITS: Array[Vector2];


var are_limits_active := true;
func optional_extras():
	if(are_limits_active):
		var i = 0;
		for limits_set in WHEN_WITHIN_LIMITS:
			if(len(IMPOSED_LIMITS_ROTATEABLES) <= i):
				push_warning("Limits set, but no correlating limits object")
				are_limits_active = false
				return
			elif(IMPOSED_LIMITS_ROTATEABLES[i] == null):
				push_warning("Limits set, but no correlating limits object")
				are_limits_active = false
				return
			else:
				if insertion > limits_set.x and insertion < limits_set.y:
					IMPOSED_LIMITS_ROTATEABLES[i].ACTIVE = true;
				else:
					IMPOSED_LIMITS_ROTATEABLES[i].ACTIVE = false;
			i += 1;
