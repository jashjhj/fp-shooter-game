class_name Gun_Insertable_Chamberable_Round extends Gun_Insertable_Droppable

##Is a live round
@export var is_live:bool = true

@export var BULLET_SOURCE:Gun_Part_BulletSource;

signal fire

func _ready():
	super._ready()
	fire.connect(triggered)

func triggered():
	if(is_live):
		is_live = false;
		BULLET_SOURCE.shoot.emit();
