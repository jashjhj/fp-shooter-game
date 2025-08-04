class_name Trig_Depropogate_Impulse extends Triggerable
@export var IMPULSE_TO_DEPROPOGATE:Hit_Impulse;
@export var IMPULSE_PROPOGATOR:Hit_Impulse_Propogate

func trigger():
	super.trigger()
	if(IMPULSE_TO_DEPROPOGATE != null and IMPULSE_PROPOGATOR != null):
		for i in range(0,len(IMPULSE_PROPOGATOR.IMPULSE_UPSTREAMS)):
			if IMPULSE_PROPOGATOR.IMPULSE_UPSTREAMS[i] == IMPULSE_TO_DEPROPOGATE:
				IMPULSE_PROPOGATOR.IMPULSE_UPSTREAMS.remove_at(i)
				return
