class_name Hit_Impulse_Repropogate extends Hit_Impulse_Propogate


#This script doesnt really work tbf

var mass_sum:float = 0.0;
var previous_repropogator:Hit_Impulse_Repropogate;

func hit(damage:float):
	if(!DISABLE_UPSTREAM):
		var eligible:Array[Hit_Impulse]
		
		for i in IMPULSE_UPSTREAMS:
			if(i != null):
				eligible.append(i)
		
		var has_been_reprop:bool = false;
		
		if(len(eligible) > 0): # If there are eligible objects to pass on impulse
			for e in eligible:
				e.trigger(damage/len(eligible), last_impulse/len(eligible), last_impulse_pos)
				
				if(e is Hit_Impulse_Repropogate):
					if(IMPULSE_TO == null): continue
					e.mass_sum = (mass_sum + IMPULSE_TO.mass) / float(len(eligible));
					has_been_reprop = true
			
			if(!has_been_reprop):
				propogate_up()
			
			return
	# If none eligible, carry on to IMPULSE_TO
	
	if IMPULSE_TO == null or !IMPULSE_TO is RigidBody3D: return
	IMPULSE_TO.apply_impulse(last_impulse, last_impulse_pos - IMPULSE_TO.global_position)



func propogate_up():
	if(IMPULSE_TO == null): return
	
	#Apply this part of the impulse to this element
	IMPULSE_TO.apply_impulse(last_impulse * (IMPULSE_TO.mass/mass_sum), last_impulse_pos - IMPULSE_TO.global_position)
	if(previous_repropogator != null): previous_repropogator.propogate_up()
	
	mass_sum = 0;
