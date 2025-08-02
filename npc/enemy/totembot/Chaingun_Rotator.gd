class_name Chaingun_Rotator extends Node3D

##Axis to rotate around, locally. Flip to change direction.
@export var ROTATE_AROUND:Vector3 = Vector3.FORWARD

##Also acts as the 'pickup' point
@export var AMMO_INSTANCE:Node

##Numebr of slots
@export var SLOTS_NUM:int = 4;

@export var ANGLE_TO_COLLECT:float = 0
@export var ANGLE_TO_FIRE:float = PI
@export var ANGLE_TO_EJECT:float = 3*PI/2

@export var TRIGGERABLE_FIRE:Triggerable

@export var TRIGGERABLE_EJECT:Triggerable
##Called every time the rotator rotates one slot.   Hardcoded work for sound Player
@export var TRIGGERABLE_CLICK:Triggerable


##Radians/second^2
@export var ROT_ACCELERATION:float = 3.2;
##Radians/second
@export var ROT_MAX_SPEED:float = 32;
@export var CLICKS_BEFORE_FIRE:int = 4;

var is_spinning:bool = false:
	set(v):
		is_spinning = v
		clicks = 0
var clicks:int = 0;

class Slot:
	var contents:Node3D
	var is_populated:float:
		set(v):
			is_populated = v
			if(contents != null):
				if(is_populated):
					contents.visible = true
				else:
					contents.visible = false;
	var is_fired:bool = false;

var SLOTS:Array[Slot]


var rotation_speed:float = 0.0;
var angle:float = 0.0;

var new;

func _ready() -> void:
	
	
	
	for i in range(0, SLOTS_NUM):
		SLOTS.append(Slot.new())
		SLOTS[i].contents = AMMO_INSTANCE.duplicate()
		
		add_child(SLOTS[i].contents)
		SLOTS[i].contents.global_transform = AMMO_INSTANCE.global_transform
		SLOTS[i].contents.position = SLOTS[i].contents.position.rotated(ROTATE_AROUND, 2*PI/SLOTS_NUM * i)
		
		SLOTS[i].is_populated = false
	
	AMMO_INSTANCE.visible = false

#manager to trigger funcs when each slot passes thing
func _physics_process(delta: float) -> void:
	
	#get_tree().root.add_child.call_deferred(new)
	
	
	#calc rot speed
	if(is_spinning):
		rotation_speed += ROT_ACCELERATION * delta
		rotation_speed = min(rotation_speed, ROT_MAX_SPEED)
	else:
		pass
		rotation_speed *= 0.5 ** delta # hlave spee devery second
	
	var next_rotation:float = rotation_speed*delta
	
	
	for i in range(0, SLOTS_NUM):
		var slot_angle_offset:float = (2*PI / SLOTS_NUM) * i
		var current_angle := angle + slot_angle_offset
		var next_angle := angle + slot_angle_offset + next_rotation # No checks for loop
		
		if(is_angle_between(ANGLE_TO_COLLECT, current_angle, next_angle)):
			collect(SLOTS[i])
		
		if(is_angle_between(ANGLE_TO_FIRE, current_angle, next_angle)):
			fire(SLOTS[i])
		
		if(is_angle_between(ANGLE_TO_EJECT, current_angle, next_angle)):
			eject(SLOTS[i])
	
	
	rotate_object_local(ROTATE_AROUND, next_rotation)
	angle += next_rotation
	angle = fmod(angle, 2*PI) # Loop back down

func is_angle_between(angle:float, lower:float, higher:float) -> bool:
	if(higher > angle and angle > lower) or (higher > angle+2*PI and angle+2*PI > lower):
		return true
	else: return false



func collect(slot:Slot):
	if(!slot.is_populated):
		slot.is_populated = true
		
		slot.is_fired = false

func fire(slot:Slot):
	
	
	if(TRIGGERABLE_CLICK != null):
		if(TRIGGERABLE_CLICK is Triggerable_Sound_Effect):
			TRIGGERABLE_CLICK.PITCH_OFFSET = 0.033
			TRIGGERABLE_CLICK.PITCH_ORIGIN = 0.8 + log(1+rotation_speed) * 0.1
		TRIGGERABLE_CLICK.trigger() # Always click
	
	if(clicks < CLICKS_BEFORE_FIRE): ## If not yet ready to fire
		clicks += 1;
		return
	
	if(slot.is_populated and !slot.is_fired and is_spinning):
		
		if(TRIGGERABLE_FIRE != null): TRIGGERABLE_FIRE.trigger()
		
		slot.is_fired = true

func eject(slot:Slot):
	if(slot.is_populated and slot.is_fired):
		
		if(TRIGGERABLE_EJECT != null):
			
			
			TRIGGERABLE_EJECT.trigger()
		
		slot.is_populated = false


#funcs that tkae a slot and then perform functions ie Fire then make not live.




func start_firing():
	is_spinning = true

func stop_firing():
	is_spinning = false
