class_name Hit_Pastel extends Hit_HP_Tracker

@export var PASTEL:Pastel_Colour_Mesh

@export var SHOW_DAMAGE_HIGHLIGHT:bool = true
@export var DAMAGE_HIGHLIGHT_MINIMUM:float = 1.0;

@onready var damage_timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	add_child(damage_timer)
	damage_timer.timeout.connect(disable_highlight)



func hit(damage:float) -> void:
	super.hit(damage)
	
	PASTEL.health -= (damage-MINIMUM_DAMAGE_THRESHOLD) / float(MAX_HP)
	
	if(SHOW_DAMAGE_HIGHLIGHT and damage > DAMAGE_HIGHLIGHT_MINIMUM):
		enable_highlight()
		damage_timer.start(0.1)





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
	
	PASTEL.HIGHLIGHT_ENABLED = highlight_enabled
	PASTEL.HIGHLIGHT_THROUGH_OBJECTS = highlight_through
	PASTEL.HIGHLIGHT_COLOUR = highlight_color
	
	is_damage_highlight_on = false
