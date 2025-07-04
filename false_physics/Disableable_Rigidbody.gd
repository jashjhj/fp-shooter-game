class_name Disableable_Rigidbody extends RigidBody3D

@export var DISABLE_LINKED:Array[Node];

var disabled = false:
	set(value):
		disabled = value
		if(disabled):
			freeze = true
			
			for item in DISABLE_LINKED:
				if(item is Disableable_Rigidbody):
					item.disabled = true
				else:
					item.process_mode = Node.PROCESS_MODE_DISABLED
			
		else:
			freeze = false
			
			for item in DISABLE_LINKED:
				if(item is Disableable_Rigidbody):
					item.disabled = false
				else:
					item.process_mode = Node.PROCESS_MODE_INHERIT
