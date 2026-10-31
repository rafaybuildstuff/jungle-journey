extends CanvasLayer

@export_multiline var dialogue_text: String = "Me :\nWhaoo! Whats That"

@onready var dialogue_label: Label = $BannerContainer/Label

func _ready() -> void:
	# Keep processing script even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if dialogue_label:
		dialogue_label.text = dialogue_text
	
	# Keep hidden on startup
	hide()

# Call this function when the player touches the Area2D message trigger
func trigger_dialogue() -> void:
	show()
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	# Only listen for key presses while the banner is visible
	if not visible:
		return
		
	# Check if player presses Enter, Keypad Enter, or Escape
	if event.is_pressed() and not event.is_echo():
		if event is InputEventKey:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_ESCAPE:
				close_dialogue()

func close_dialogue() -> void:
	# Unpause the game world and hide the banner
	get_tree().paused = false
	hide()
