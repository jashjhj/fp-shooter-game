class_name Gun extends Player_Tool




##Set to the default bullet scene
#var bullet:PackedScene = load("res://gameobjects/bullets/bullet.tscn");
@export var trigger_functions:Array[Triggerable];
@export var trigger_functions_continuous:Array[Triggerable];

@export var STRAP_TO_TORSO:Array[Node3D];


func _ready() -> void:
	super._ready();
	
	
	
	for child in get_all_children(self):
		if child is Tool_Part:
			child.PARENT_GUN = self;
	




func _process(_delta:float):
	super._process(_delta)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if(interact_0):
		for t in trigger_functions_continuous:
			t.trigger()



func focus_set(v):
	if(v):
		for c in get_all_children(self):
			if c is Tool_Part_Interactive:
				c.is_focusable = v;
			





func inspect_set(value):
	super.inspect_set(value)
	
	if(inspect):
		for child in get_all_children(self):
			if child is Tool_Part_Interactive:
				child.is_interactive = true;
		
		#MODEL_POSITION_INSPECT.transform = default_inspect_transform;
	
	else: # interacting disabled.
		for child in get_all_children(self):
			if child is Tool_Part_Interactive:
				child.is_interactive = false;


func interact_0_set(value):
	super(value)
	
	if(interact_0):
		for listener in trigger_functions:
			listener.trigger();
	


##Recursive get_children
func get_all_children(node) -> Array:
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes
