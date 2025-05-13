class_name RubbishCollector extends Node

@export var RUBBISH:Array[Node];
var front_pointer = 0;
var end_pointer = 0;
var max_rubbish:int;

func _ready():
	max_rubbish = Settings.Max_Rubbish
	Globals.RUBBISH_COLLECTOR = self;

func add_rubbish(node:Node):
	if(max_rubbish != Settings.Max_Rubbish): clear_rubbish(); # if change to max, reset
	
	
	if(len(RUBBISH) <= front_pointer): # add next rubbish
		RUBBISH.append(node);
	else:
		RUBBISH[front_pointer] = node;
	front_pointer += 1;
	
	if(len(RUBBISH) >= Settings.Max_Rubbish): # prune excess rubbish
		if(RUBBISH[end_pointer] != null):
			RUBBISH[end_pointer].queue_free(); # frees up excess rubbish
		end_pointer += 1;
	
	if(front_pointer >= Settings.Max_Rubbish): # loop the queue
		front_pointer = 0;
	if(end_pointer >= Settings.Max_Rubbish):
		end_pointer = 0;
	
	

func clear_rubbish():
	for tat in RUBBISH:
		if(tat != null):
			tat.queue_free()
	RUBBISH = [];
	front_pointer = 0;
	end_pointer = 0;
