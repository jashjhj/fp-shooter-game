extends Node3D

@export var START_SEGMENT:PackedScene;
@export var LEVEL_SEGMENTS:Array[PackedScene]
@export var LEVEL_SEGMENT_WEIGHTS:Array[float]

@export var BUDGET:float = 30.0;

var loading_level:bool = false;

const TRIES_UNTIL_FAILURE:int = 10;

func _ready() -> void:
	assert(len(LEVEL_SEGMENTS) == len(LEVEL_SEGMENT_WEIGHTS), "Mismatching level segment weights vs segments")
	
	normalise_weights()
	load_level()


signal run_load_step
signal finished_loading

func load_level() -> void:
	loading_level = true;
	
	var outbound_connections:Array[Level_Segment_Connector]
	
	var new_seg:Level_Segment = load_segment(START_SEGMENT, Vector3(0, -10, 0), Basis.IDENTITY)
	if(new_seg != null):
		outbound_connections.append_array(new_seg.OUTBOUND);
	
	
	while BUDGET > 0:
		var TRIES:int = TRIES_UNTIL_FAILURE
		if(len(outbound_connections) == 0): return # Run out of connections
		
		while TRIES > 0:
			TRIES -= 1;
			
			var outbound_connection_index:int = randi_range(0, len(outbound_connections)-1);
			var outbound = outbound_connections[outbound_connection_index]
			var new_segment = load_segment_from_node(pick_weighted_random_segment(), outbound)
			
			if(new_segment.INBOUND.TYPE != outbound.TYPE):
				new_segment.free()
				continue # Invalid
			
			await run_load_step
			
			if(new_segment.BOUNDING_BOX.has_overlapping_areas()):
				new_segment.free()
			
			if(new_segment != null):
				BUDGET -= new_segment.COST;
				
				outbound_connections.append_array(new_segment.OUTBOUND)
				
				TRIES = 0; # Enter next cycle & remove conenction index
			
			if(TRIES == 0): # This one is invalid
				outbound_connections.remove_at(outbound_connection_index)
		pass
	finished_loading.emit()
	loading_level = false


func _physics_process(delta: float) -> void:
	if(loading_level):
		run_load_step.emit()


func pick_weighted_random_segment() -> PackedScene:
	var selection = randf();
	var i = 0;
	while selection > 0:
		if(selection < LEVEL_SEGMENT_WEIGHTS[i]):
			return LEVEL_SEGMENTS[i]
		selection -= LEVEL_SEGMENT_WEIGHTS[i]
		i += 1;
	
	assert(true, "Should not have gotten here")
	return null


func load_segment_from_node(segment:PackedScene, node:Node3D) -> Level_Segment:
	return load_segment(segment, node.global_position - global_position, node.global_basis)

func load_segment(segment:PackedScene, pos:Vector3, orientation:Basis) -> Level_Segment:
	var seg = segment.instantiate()
	assert(seg is Level_Segment, "Assigned segment is not PackedScene of a LevelSegment");
	seg = seg as Level_Segment
	
	add_child(seg)
	
	seg.basis = seg.global_basis * seg.INBOUND.global_basis.inverse() * orientation
	seg.position = - seg.INBOUND.global_position + seg.global_position + pos;
	
	
	
	return seg


##Normalises LEVEL_SEGMENT_WEIGHTS so sum = 1
func normalise_weights() -> void:
	var sum:float = 0;
	for weight in LEVEL_SEGMENT_WEIGHTS:
		sum += weight;
	
	for i in range(0, len(LEVEL_SEGMENT_WEIGHTS)):
		LEVEL_SEGMENT_WEIGHTS[i] /= sum
