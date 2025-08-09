@tool
class_name Body_Segment extends Node3D

##This acts as its own little locally-sources Hit_Impulse_Propogate for propogating upstream.
@export var IMPULSE_UPSTREAMS:Array[Hit_Impulse]
##The <Hit_Impulse_Propogate> (Local to this object) via which impulses are propagated through, leaving the <Body_Segment>.
@export var IMPULSE_PROPOGATOR:Hit_Impulse_Propogate


signal on_destroy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(IMPULSE_PROPOGATOR != null):
		IMPULSE_PROPOGATOR.IMPULSE_UPSTREAMS.append_array(IMPULSE_UPSTREAMS)

##Called to 'destory' part - trigger gibs, etc.
func destroy() -> void:
	on_destroy.emit()
	
