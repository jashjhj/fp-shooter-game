extends Gun_Insertable

@export var MAX_CAPACITY:int = 5;
@export var STORING:int = 4;

@export var AMMO_OBJECT:Node3D;
@export var AMMO_POSITIONS:Array[Node3D];

var AMMO_SPRITES:Array[Node3D]; # for access

@export var MAG_SPRING:Node3D;

func _ready():
	super._ready()
	
	populate_mag()

func _process(delta: float) -> void:
	super._process(delta)
	if(MAG_SPRING != null):
		MAG_SPRING.scale.y = 1.0-(float(STORING)/float(MAX_CAPACITY));

func populate_mag():
	AMMO_SPRITES = [];
	
	for i in range(0, MAX_CAPACITY):
		if(len(AMMO_POSITIONS) > i):
			if(AMMO_POSITIONS[i] != null):
				var new_object:Node3D =AMMO_OBJECT.duplicate()
				AMMO_SPRITES.append(new_object);
				new_object.transform = AMMO_POSITIONS[i].transform
	
	set_ammo_visibilities()

func set_ammo_visibilities():
	for i in range(0, len(AMMO_SPRITES)):
		if(AMMO_SPRITES[i] != null):
			if(STORING > i): # If this one is on
				AMMO_SPRITES[i].visible = true
			else:
				AMMO_SPRITES[i].visible = false;
		
