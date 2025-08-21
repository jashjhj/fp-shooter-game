class_name Tool_Part_DA_Hammer_Cocker extends Tool_Part_Rotateable

@export var HAMMER:Tool_Part_Interactive_1D

@export var TRIGGER_START:float;
@export var TRIGGER_END:float;
@export var HAMMER_DECOCK:float;
@export var HAMMER_COCK:float;

@onready var hammer_cocker:Map_Constraint_Linear_Min = Map_Constraint_Linear_Min.new()
@onready var trigger_cocker:Map_Constraint_Linear_Min = Map_Constraint_Linear_Min.new();

@onready var fully_cock_triggerable:Triggerable = Triggerable.new();
@onready var reset_cock_triggerable:Triggerable = Triggerable.new();

##Ready
func _ready():
	super._ready();
	
	hammer_cocker.PRIMARY = self
	hammer_cocker.SECONDARY = HAMMER
	hammer_cocker.DOMAIN_START = TRIGGER_START # tolerances so it can slide, wont get stuck.
	hammer_cocker.DOMAIN_END = TRIGGER_END
	hammer_cocker.RANGE_START = HAMMER_DECOCK - 0.31
	hammer_cocker.RANGE_END = HAMMER_COCK - 0.31
	
	
	trigger_cocker.PRIMARY = HAMMER
	trigger_cocker.SECONDARY = self
	trigger_cocker.DOMAIN_START = HAMMER_DECOCK
	trigger_cocker.DOMAIN_END = HAMMER_COCK
	trigger_cocker.RANGE_START = TRIGGER_START - 0.04
	trigger_cocker.RANGE_END = TRIGGER_END - 0.04

	
	#Connect triggers
	fully_cock_triggerable.on_trigger.connect(fully_cock)
	reset_cock_triggerable.on_trigger.connect(reset_cock)
	
	TRIGGERS_TRIGGERABLE.append(fully_cock_triggerable)
	TRIGGERS_DIRECTION.append(TRIGGERS_DIRECTION_ENUM.FORWARDS)
	TRIGGERS_DISTANCE.append(TRIGGER_END)
	
	TRIGGERS_TRIGGERABLE.append(reset_cock_triggerable)
	TRIGGERS_DIRECTION.append(TRIGGERS_DIRECTION_ENUM.BACKWARDS)
	TRIGGERS_DISTANCE.append(TRIGGER_START)
	
	
	
	add_child(hammer_cocker)
	add_child(trigger_cocker)




func _process(delta:float) -> void:
	super._process(delta);

func _physics_process(delta:float) -> void:
	super._physics_process(delta);



func fully_cock():
	hammer_cocker.is_enabled = false
	trigger_cocker.is_enabled = false
	
	pass

func reset_cock():
	hammer_cocker.is_enabled = true
	trigger_cocker.is_enabled = true
	
	pass
