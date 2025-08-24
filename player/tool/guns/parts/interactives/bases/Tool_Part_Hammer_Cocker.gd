class_name Tool_Part_DA_Hammer_Cocker extends Tool_Part_Rotateable

@export var HAMMER:Tool_Part_Interactive_1D

@export var CONSTRAINT:Mechanism_2Way_Mapper;

@export var RELEASE_HAMMER:float = 0.48
@export var RELEASE_HAMMER_TRIGGER:Triggerable;




##Ready
func _ready():
	super._ready();
	
	
	
	#Connects triggers
	add_new_trigger(RELEASE_HAMMER, TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(release_hammer)
	add_new_trigger(CONSTRAINT.SECONDARY_END, TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(disengage_link)
	
	
	#add_new_trigger(RELEASE_HAMMER, TRIGGERS_DIRECTION_ENUM.).connect(engage_link)
	
	




func _process(delta:float) -> void:
	super._process(delta);



func _physics_process(delta:float) -> void:
	super._physics_process(delta);
	
	#print(DISTANCE)
	
	
	if(!is_link_engaged()): # when 'caught' so the double actioness shoudl engage, & its not beyond the point fo no return
		if(CONSTRAINT.secondary_to_primary(CONSTRAINT.SECONDARY.DISTANCE) <= CONSTRAINT.PRIMARY.DISTANCE and DISTANCE <= CONSTRAINT.SECONDARY_END): # engages when 'caught' by trigger
			engage_link()


#func fully_cock():
	#call_deferred("release_hammer") # calls deferered so ti ahppens next tick, so hammer cna be updated.
	#
	#pass

func release_hammer():
	#print("drop")
	RELEASE_HAMMER_TRIGGER.trigger()
	disengage_link()

func disengage_link():
	
	CONSTRAINT.is_enabled = false
	velocity = 0;

func engage_link():
	CONSTRAINT.is_enabled = true

func is_link_engaged():
	return CONSTRAINT.is_enabled
