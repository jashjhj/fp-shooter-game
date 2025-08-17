class_name Gun_Action extends Gun_Part

@export var ACTION_SLIDEABLE_LINK:Gun_Part_Slideable;

@export var FIRE_TRIGGER:Triggerable;
@export var EJECT_TRIGGER:Triggerable
@export var GATHER_TRIGGER:Triggerable;

@export var GATHER_FROM:Gun_Part_Insertable_Slot;

##Determines the position of the round, etc. A child of the Slideable link
@export var ROUND_ANCHOR:Node3D;

@export_group("Ejection Data")
@export var EJECTION_VELOCITY:Vector3 = Vector3.RIGHT;
@export var EJECTION_VELOCITY_ANGULAR:Vector3 = Vector3.ZERO
#Multiplies ejection velocity by 1+(this multiplier * speed at which ejected) 
@export var EJECTION_SPEED_MULTIPLIER = 1.0;

@export_group("Extras")
@export var TRIGGER_ON_FIRE:Array[Action_Node];



var current_round:Gun_Round = null;

func _ready() -> void:
	assert(ACTION_SLIDEABLE_LINK != null, "No slideable link set")
	assert(GATHER_FROM != null, "No gather-from point set")
	
	#ACTION_SLIDEABLE_LINK.add_child(action_node)
	
	EJECT_TRIGGER.on_trigger.connect(eject)
	GATHER_TRIGGER.on_trigger.connect(gather)
	FIRE_TRIGGER.on_trigger.connect(fire)
	
	if(ROUND_ANCHOR == null):
		ROUND_ANCHOR = Node3D.new()
		ACTION_SLIDEABLE_LINK.add_child(ROUND_ANCHOR)




var prev_slide_pos:float = 0;


var prev_pos:Vector3 = Vector3.ZERO;
var velocity:Vector3;
var prev_angles:Vector3 = Vector3.ZERO;
var velocity_angular:Vector3;

func _physics_process(delta: float) -> void:
	velocity = (global_position - prev_pos) / delta
	prev_pos = global_position;
	velocity_angular = (global_rotation - prev_angles) / delta
	prev_angles = global_rotation
	
	
	
	
	var slide_pos:float = ACTION_SLIDEABLE_LINK.slide_pos # Ejection/Feeding
	
	
	#action_node.global_position = global_position + ACTION_SLIDEABLE_LINK.visual_slide_pos*(ACTION_SLIDEABLE_LINK.global_basis*ACTION_SLIDEABLE_LINK.SLIDE_VECTOR)
	
	
	
	prev_slide_pos = slide_pos


func gather() -> void:
	if(current_round != null): return
	if(GATHER_FROM.is_housed):
		var mag = GATHER_FROM.housed_insertable;
		if(mag is Gun_Insertable_Mag):
			current_round = mag.feed()
			if(current_round != null): # With the new bullet,
				ROUND_ANCHOR.add_child(current_round);
				current_round.position = Vector3.ZERO
				current_round.basis = Basis.IDENTITY
		else:
			print("Unknown type in insertable slot - not recognised as -Mag- by Action")
	pass


func eject() -> void:
	
	if(current_round == null):
		return
	
	
	var eject_speed_mult = 1 + EJECTION_SPEED_MULTIPLIER*sqrt(abs(ACTION_SLIDEABLE_LINK.prev_velocity))
	
	
	Globals.RUBBISH_COLLECTOR.add_rubbish(current_round)
	current_round.reparent(Globals.RUBBISH_COLLECTOR)
	current_round.enable_rigidbody()
	current_round.RIGIDBODY.linear_velocity = velocity + global_basis*EJECTION_VELOCITY * eject_speed_mult
	current_round.RIGIDBODY.angular_velocity = velocity_angular + global_basis*EJECTION_VELOCITY_ANGULAR * eject_speed_mult
	current_round = null
	pass

func fire() -> void:
	#If harbouring a round, tis live, and seated
	if(current_round != null and current_round.is_live and abs(ACTION_SLIDEABLE_LINK.slide_pos - ACTION_SLIDEABLE_LINK.SLIDE_DISTANCE) < 0.05):
		current_round.fire.emit()
		
		for trigger in TRIGGER_ON_FIRE:
			trigger.trigger.emit();
