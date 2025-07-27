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

@onready var is_hp_positive:bool = MAX_HP >= 0


##Emitted after a hit which reduces HP to <0
signal on_hp_becomes_negative

func _ready() -> void:
	HP = MAX_HP

## || Please call super.hit() before processing if extending this class
func hit(damage:float) -> void:
	
	if(damage > MINIMUM_DAMAGE_THRESHOLD):
		HP -= damage - MINIMUM_DAMAGE_THRESHOLD
		#Logic now resides within setter.
