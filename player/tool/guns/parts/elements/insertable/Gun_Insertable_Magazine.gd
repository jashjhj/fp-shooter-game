class_name Gun_Insertable_Mag extends Gun_Insertable_Droppable

@export var MAX_CAPACITY:int = 5;
@export var STORING:int = 4;



@export_group("Cosmetics")
@export var AMMO_OBJECT:Gun_Round;
@export var AMMO_POSITIONS:Array[Node3D];

var AMMO_SPRITES:Array[Node3D]; # for access

@export var MAG_SPRING:Node3D;
@export var MAG_MIN_EXTENSION_SCALE:float = 0.1;
@export var MAG_MAX_EXTENSION_SCALE:float = 1.0;

func _ready():
	AMMO_OBJECT.visible = false;
	AMMO_OBJECT.process_mode = Node.PROCESS_MODE_DISABLED
	free_ammo_pos_children()
	super._ready()
	
	#Setup cosmetics
	populate_mag()
	set_ammo_visibilities()
	set_spring_scale()

func _process(delta: float) -> void:
	super._process(delta)




func feed() -> Gun_Round:
	if(STORING == 0):
		return null
	STORING -= 1;
	
	set_ammo_visibilities(STORING)
	set_spring_scale()
	var new_object := AMMO_OBJECT.duplicate()
	new_object.visible = true;
	return new_object
	
	










func set_spring_scale():
	if(MAG_SPRING != null):
		MAG_SPRING.scale.y = lerpf(MAG_MAX_EXTENSION_SCALE, MAG_MIN_EXTENSION_SCALE, (float(STORING)/float(MAX_CAPACITY)));


#Frees them, so youc an set them in-editor beforehand to check & its cleared at runtime
func free_ammo_pos_children():
	for node in AMMO_POSITIONS:
		if node != null:
			for node_child in node.get_children():
				node_child.free()

func populate_mag():
	free_ammo_pos_children()
	AMMO_SPRITES = [];
	
	for i in range(0, MAX_CAPACITY):
		if(len(AMMO_POSITIONS) > i):
			if(AMMO_POSITIONS[i] != null):
				var new_object:Node3D = AMMO_OBJECT.duplicate()
				AMMO_SPRITES.append(new_object);
				
				new_object.visible = true;
				new_object.process_mode = Node.PROCESS_MODE_INHERIT
				AMMO_POSITIONS[i].add_child(new_object)
				new_object.global_transform = AMMO_POSITIONS[i].global_transform


func set_ammo_visibilities(specific_index:int = -1):
	if(specific_index <= -1):
		for i in range(0, len(AMMO_SPRITES)):
			if(AMMO_SPRITES[i] != null):
				if(STORING > i): # If this one is on
					AMMO_SPRITES[i].visible = true
				else:
					AMMO_SPRITES[i].visible = false;
	
	else:#Specific index set - only compute that one
		if(specific_index < len(AMMO_SPRITES)):
			if(AMMO_SPRITES[specific_index] != null):
				if(STORING > specific_index): # If this one is on
					AMMO_SPRITES[specific_index].visible = true
				else:
					AMMO_SPRITES[specific_index].visible = false;
		
