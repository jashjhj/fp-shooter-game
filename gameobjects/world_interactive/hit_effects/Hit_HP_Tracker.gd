class_name Hit_HP_Tracker extends Hit_Component



@export var MAX_HP:float = 5;
##Acts like a shield - Subtracted from incoming damage.
@export var MINIMUM_DAMAGE_THRESHOLD:float = 1;

var HP:float:
	set(v):
		HP = v;
		if HP <= 0 and is_hp_positive:
			is_hp_positive = false;
			on_hp_becomes_negative.emit()
		on_hp_change.emit(HP)

@onready var is_hp_positive:bool;


##Emitted after a hit which reduces HP to <0
signal on_hp_becomes_negative
signal on_hp_change(new_hp:float)

##Remember to call super._ready
func _ready() -> void:
	super()
	HP = MAX_HP
	if(HP > 0): is_hp_positive = true

## || Please call super.hit() before processing if extending this class
func hit(damage:float) -> void:
	
	if(damage > MINIMUM_DAMAGE_THRESHOLD):
		HP -= damage - MINIMUM_DAMAGE_THRESHOLD
		#Logic now resides within setter.
