class_name Config_File_Handler extends Node

var config = ConfigFile.new();
const SETTINGS_FILE_PATH = "user://settings.ini"



func init():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		save_settings()
	else:
		config.load(SETTINGS_FILE_PATH);
		load_settings()
	
	tree_exiting.connect(save_settings)
	# Temporary - Until actual settings menu implemented. Resets on laod each time.
	#print_debug("Setting keybinds")


## Set function act to keybindging binding
func save_keybinding(action:StringName, event:InputEvent) -> bool:
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode);
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	else: # Failed
		push_warning("Invalid/unrecognised binding failed to save.")
		return false;
	
	# save and close
	config.set_value("keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)
	return true
	




func save_settings():
	config.set_value("mouse", "look_sensitivity", Settings.Mouse_LookSensitivity);
	config.set_value("mouse", "ads_sensitivity_mult", Settings.Mouse_AimSensitivity);
	config.set_value("mouse", "interact_sensitivity", Settings.Mouse_InteractSensitivity);
	
	reset_keybindings()
	
	config.save(SETTINGS_FILE_PATH);

func load_settings():
	load_keybindings()
	
	Settings.Mouse_LookSensitivity = config.get_value("mouse", "look_sensitivity", 1.0); # these are defualts
	Settings.Mouse_AimSensitivity = config.get_value("mouse", "ads_sensitivity_mult", 0.5);
	Settings.Mouse_InteractSensitivity = config.get_value("mouse", "interact_sensitivity", 1.0);



func load_keybindings():
	var keybindings = {};
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding", key)
		
		if(event_str.contains("mouse_")):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1]);
		elif(len(event_str) == 1): # key
			input_event = InputEventKey.new();
			input_event.keycode = OS.find_keycode_from_string(event_str)
		else:
			push_warning("Unrecognised keyevent in config file: `" + event_str + "` Under `keybinding::" + key + "`");
			continue
		
		keybindings[key] = input_event;
	
	return keybindings;

func set_keybindings():
	var keybindings = load_keybindings()
	
	for action in keybindings.keys():
		InputMap.action_erase_events(action); # sets and saves keybindings.
		InputMap.action_add_event(action, keybindings[action]);


## Set config to default - beacsue load them wont leave auto-sets. 
func reset_keybindings():
	# CATEGORY, action, binding
	config.set_value("keybinding", "move_forward", "W");
	config.set_value("keybinding", "move_backward", "S");
	config.set_value("keybinding", "move_left", "A");
	config.set_value("keybinding", "move_right", "D");
	
	config.set_value("keybinding", "interact_0", "mouse_1");
	config.set_value("keybinding", "focus", "mouse_2");
	
	
