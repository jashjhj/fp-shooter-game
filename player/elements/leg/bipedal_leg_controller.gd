class_name Bipedal_Leg_Controller extends Node

@export var LEFT_LEG:Player_Leg;
@export var RIGHT_LEG:Player_Leg;

@export var STRIDE:float = 0.4;

## 0 = Left, 1 = Right -- Current leg is one currently stood upon
var current_leg:int = 1;

func _ready() -> void:
	#LEFT_LEG.DOWN_RAY.position.z -= 0.1
	#RIGHT_LEG.DOWN_RAY.position.z -= 0.1
	pass

func _physics_process(delta: float) -> void:
	process_walking()


func process_walking() -> void:
	
	if(current_leg == 0): # Left
		
		LEFT_LEG.set_leg_stationary()
		
		var right_leg_goal:Vector3 = RIGHT_LEG.DOWN.global_position + RIGHT_LEG.DOWN.global_position - RIGHT_LEG.CURRENT.global_position
		RIGHT_LEG.goal_pos = right_leg_goal # Overwrites goal wihtout setting previous, to keep seamlessness
		
		var distance:float = LEFT_LEG.DOWN.global_position.distance_to(LEFT_LEG.CURRENT.global_position)
		RIGHT_LEG.set_leg_progress(distance/(STRIDE/2.0))
		
		print(distance)
		
		if(distance > STRIDE/2.0):
			current_leg = 1;
			RIGHT_LEG.CURRENT.global_position = RIGHT_LEG.DOWN.global_position
			LEFT_LEG.CURRENT.global_position = LEFT_LEG.DOWN.global_position# + 0.9*(LEFT_LEG.GOAL.global_position - LEFT_LEG.CURRENT.global_position)
			LEFT_LEG.set_leg_target(LEFT_LEG.DOWN.global_position, false)
			LEFT_LEG.set_leg_progress(0)
			RIGHT_LEG.set_leg_stationary()
		
		
		pass
	elif(current_leg == 1): #Right
		
		RIGHT_LEG.set_leg_stationary()
		
		var left_leg_goal:Vector3 = LEFT_LEG.DOWN.global_position + LEFT_LEG.DOWN.global_position - LEFT_LEG.CURRENT.global_position
		LEFT_LEG.goal_pos = left_leg_goal # Overwrites goal wihtout setting previous, to keep seamlessness
		
		
		var distance:float = RIGHT_LEG.DOWN.global_position.distance_to(RIGHT_LEG.CURRENT.global_position)
		LEFT_LEG.set_leg_progress(distance/(STRIDE/2.0))
		
		
		if(distance > STRIDE/2.0):
			current_leg = 0;
			LEFT_LEG.CURRENT.global_position = LEFT_LEG.DOWN.global_position
			RIGHT_LEG.CURRENT.global_position = RIGHT_LEG.DOWN.global_position# + 0.9*(RIGHT_LEG.GOAL.global_position - RIGHT_LEG.CURRENT.global_position)
			RIGHT_LEG.set_leg_target(RIGHT_LEG.DOWN.global_position, false)
			RIGHT_LEG.set_leg_progress(0)
			LEFT_LEG.set_leg_stationary()
		pass
