class_name Hit_Pastel extends Hit_HP_Tracker

@export var PASTEL:Pastel_Colour_Mesh

@export var SHOW_DAMAGE_HIGHLIGHT:bool = true
@export var DAMAGE_HIGHLIGHT_MINIMUM:float = 1.0;

@export var DISABLE_DAMAGE_HIGHLIGHT_ON_HP_0:bool = true
@export var DISABLE_HIGHLIGHT_ON_HP_0:bool = true

@onready var damage_timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(PASTEL != null, "No pastel mesh set for Hit_pastel")
	super._ready()
	add_child(damage_timer)
	damage_timer.timeout.connect(disable_highlight)
	damage_timer.one_shot = true



func hit(damage:float) -> void:

	if(PASTEL == null): return
	PASTEL.health -= max(0, (damage-MINIMUM_DAMAGE_THRESHOLD)) / float(MAX_HP)
	
	PASTEL.health = max(0.0, min(1.0, PASTEL.health))
	

	
	# IF how damage highlight and dealt damage and hp > 0 if condition required 
	if(SHOW_DAMAGE_HIGHLIGHT and (damage-MINIMUM_DAMAGE_THRESHOLD) > DAMAGE_HIGHLIGHT_MINIMUM and !(DISABLE_DAMAGE_HIGHLIGHT_ON_HP_0 and !is_hp_positive)):
		enable_highlight()
		damage_timer.start(0.15)
	
	super.hit(damage) # Must be after check for damage to see if HP WAS positive
	
	
	if(DISABLE_HIGHLIGHT_ON_HP_0 and !is_hp_positive): # If should disable highlight beacsue hp=0;
		if(!damage_timer.is_stopped()):# If timer is running, ie damage highlight is active
			highlight_enabled = false # skew settings to reset to
		else:
			PASTEL.HIGHLIGHT_ENABLED = false # If no damage active
		pass



var highlight_enabled:bool;
var highlight_through:bool;
var highlight_color:Color;

var is_damage_highlight_on:bool = false;

func enable_highlight():
	if(!is_damage_highlight_on):
		highlight_enabled = PASTEL.HIGHLIGHT_ENABLED
		highlight_through = PASTEL.HIGHLIGHT_THROUGH_OBJECTS
		highlight_color = PASTEL.HIGHLIGHT_COLOUR
	
	PASTEL.HIGHLIGHT_ENABLED = true
	PASTEL.HIGHLIGHT_THROUGH_OBJECTS = true
	PASTEL.HIGHLIGHT_COLOUR = Color(0.7, 0.0, 0.0)
	
	is_damage_highlight_on = true


func disable_highlight():
	
	is_damage_highlight_on = false
	
	if(PASTEL == null): return
	
	PASTEL.HIGHLIGHT_ENABLED = highlight_enabled
	PASTEL.HIGHLIGHT_THROUGH_OBJECTS = highlight_through
	PASTEL.HIGHLIGHT_COLOUR = highlight_color
	
