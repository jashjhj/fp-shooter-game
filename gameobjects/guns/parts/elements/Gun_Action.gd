class_name Gun_Action extends Gun_Part

@export var ACTION_SLIDEABLE_LINK:Gun_Part_Slideable;

@export var FIRE:Gun_Part_Listener;

@export var EJECT_DIST:float = 0.1
@export_enum("Forwards", "Backwards", "Both") var EJECT_WHEN_DIR:int = 1;
@export var GATHER_FROM:Gun_Part_Insertable_Slot;
@export var GATHER_DIST:float = 0.2
@export_enum("Forwards", "Backwards", "Both") var GATHER_WHEN_DIR:int = 0;

@export_group("Ejection Data")
@export var EJECTION_VELOCITY:Vector3 = Vector3.RIGHT;
@export var EJECTION_VELOCITY_ANGULAR:Vector3 = Vector3.ZERO
#Multiplies ejection velocity by 1+(this multiplier * speed at which ejected) 
@export var EJECTION_SPEED_MULTIPLIER = 1.0;

@export_group("Extras")
@export var TRIGGER_ON_FIRE:Array[Action_Node];


##Determines the position of the round, etc. A child of the Slideable link
var action_node:Node3D = Node3D.new();
var current_round:Gun_Round = null;

func _ready() -> void:
	assert(ACTION_SLIDEABLE_LINK != null, "No slideable link set")
	assert(GATHER_FROM != null, "No gather-from point set")
	
	ACTION_SLIDEABLE_LINK.add_child(action_node)
	
	assert(FIRE != null, "No fire trigger set.")
	FIRE.trigger.connect(fire)
	

var prev_slide_pos:float = 0;
func _process(_delta: float) -> void:
	var slide_pos:float = ACTION_SLIDEABLE_LINK.slide_pos
	
	if(EJECT_WHEN_DIR == 0 or EJECT_WHEN_DIR == 2): # Eject when forwards
		if(slide_pos >= EJECT_DIST and prev_slide_pos < EJECT_DIST):
			eject()
	if(EJECT_WHEN_DIR == 1 or EJECT_WHEN_DIR == 2): # Eject when backwards
		if(slide_pos <= EJECT_DIST and prev_slide_pos > EJECT_DIST):
			eject()
	
	if(GATHER_WHEN_DIR == 0 or GATHER_WHEN_DIR == 2): # Gather when forwards
		if(slide_pos >= GATHER_DIST and prev_slide_pos < GATHER_DIST):
			gather()
	if(GATHER_WHEN_DIR == 1 or GATHER_WHEN_DIR == 2): # Gather when backwards
		if(slide_pos <= GATHER_DIST and prev_slide_pos > GATHER_DIST):
			gather()
	
	action_node.global_position = global_position + ACTION_SLIDEABLE_LINK.visual_slide_pos*(ACTION_SLIDEABLE_LINK.global_basis*ACTION_SLIDEABLE_LINK.SLIDE_VECTOR)
	
	
	
	prev_slide_pos = slide_pos


var prev_pos:Vector3 = Vector3.ZERO;
var velocity:Vector3;
var prev_angles:Vector3 = Vector3.ZERO;
var velocity_angular:Vector3;
func _physics_process(delta: float) -> void:
	velocity = (global_position - prev_pos) / delta
	prev_pos = global_position;
	velocity_angular = (global_rotation - prev_angles) / delta
	prev_angles = global_rotation


func gather() -> void:
	if(current_round != null): return
	if(GATHER_FROM.is_housed):
		var mag = GATHER_FROM.housed_insertable;
		if(mag is Gun_Insertable_Mag):
			current_round = mag.feed()
			if(current_round != null): # With the new bullet,
				action_node.add_child(current_round);
				current_round.position = Vector3.ZERO
				current_round.basis = Basis.IDENTITY
		else:
			print("Unknown type in insertable slot - not recognised as -Mag- by Action")
	pass


func eject() -> void:
	if(current_round == null):
		return
	
	var eject_speed_mult = 1 + EJECTION_SPEED_MULTIPLIER*abs(ACTION_SLIDEABLE_LINK.velocity)
	
	Globals.RUBBISH_COLLECTOR.add_rubbish(current_round)
	current_round.reparent(Globals.RUBBISH_COLLECTOR)
	current_round.enable_rigidbody()
	current_round.RIGIDBODY.linear_velocity = velocity + global_basis*EJECTION_VELOCITY * eject_speed_mult
	current_round.RIGIDBODY.angular_velocity = velocity_angular + global_basis*EJECTION_VELOCITY_ANGULAR * eject_speed_mult
	current_round = null
	pass

func fire() -> void:
	if(current_round != null):
		current_round.fire.emit()
		
		for trigger in TRIGGER_ON_FIRE:
			trigger.trigger.emit();
