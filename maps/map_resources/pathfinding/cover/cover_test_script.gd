extends Node3D

@export var COVER:Cover;

var time = -10000
func _process(delta: float) -> void:
	
	if (Time.get_ticks_msec() - 10000 > time):
		time = Time.get_ticks_msec()
		draw_all(10.0)

func draw_all(time:float = 1.0):
	
	var probes_size_x = int(2*float(COVER.DISTANCE)/COVER.DISTANCE_BETWEEN_PROBES+2)
	var probes_size_z = int(2*float(COVER.DISTANCE)/COVER.DISTANCE_BETWEEN_PROBES+2)
	for x_i in range(0, probes_size_x):
		var x:float = (x_i) * COVER.DISTANCE_BETWEEN_PROBES - COVER.DISTANCE
		for y_i in range(0, probes_size_z):
			var y:float = (y_i) * COVER.DISTANCE_BETWEEN_PROBES - COVER.DISTANCE
			
			var distances := COVER.get_distances_at(COVER.global_position + Vector3(x, 0, y))
			
			for i in range(0, len(distances)):
				var _s = DebugDraw3D.new_scoped_config().set_thickness(0)
				var line_start = Vector3(-x, 5, -y)
				var line_end = line_start + distances[i]*Vector3.FORWARD.rotated(Vector3.UP, float(i)/float(COVER.PROBES_NUMBER) * 2*PI)
				
				if(distances[i] != COVER.PROBES_LENGTH):
					DebugDraw3D.draw_arrow(line_start, line_end, Color(1,0,0), 0.1, true, time)
