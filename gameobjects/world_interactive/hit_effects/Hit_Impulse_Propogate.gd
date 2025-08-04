class_name Hit_Impulse_Propogate extends Hit_Impulse

@export_category("Will first attempt IMPULSE_UPSTREAM")
##if cannot find this, resort to IMPULSE_TO. Array: Spreads out the impulse evenly between all that apply.  | If this array6 is blank, resorts to IMPUSLE_TO
@export var IMPULSE_UPSTREAMS:Array[Hit_Impulse];

##Toggle this to true to enforce not going upstream. If wanting to enforce upstream (upstream or nothing), set no LOCAL.
@export var DISABLE_UPSTREAM:bool = false

func hit(damage:float):
	if(!DISABLE_UPSTREAM):
		var eligible:Array[Hit_Impulse]
		
		for i in IMPULSE_UPSTREAMS:
			if(i != null):
				eligible.append(i)
		
		if(len(eligible) > 0): # If there are eligible objects to pass on impulse
			for e in eligible:
				e.trigger(damage/len(eligible), last_impulse/len(eligible), last_impulse_pos)
			return
	
	
	if IMPULSE_TO == null: return
	IMPULSE_TO.apply_impulse(last_impulse, last_impulse_pos - IMPULSE_TO.global_position)
	
