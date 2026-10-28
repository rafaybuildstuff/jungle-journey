extends CanvasLayer

@export_multiline var girlfriend_text: String = "\"Girlfriend :\nI don't think this wood is gonna be enough to keep the campfire burning all night. Could you head out and gather a few more logs?\""
@export_multiline var player_text: String = "\"ME :\nYeah... this little bit of wood isn't lasting until morning. I'd go grab more, but my legs are completely shot. Do you mind fetching a few extra logs for the fire?\""

@onready var dialogue_label: Label = find_child("Label")

# Keeps track of what step the dialogue is on (0 = Girlfriend, 1 = Player, 2 = Done)
var dialogue_step: int = 0
var can_press: bool = true

func _ready() -> void:
	if dialogue_label:
		dialogue_label.text = girlfriend_text
	
	# PAUSE THE GAME WORLD WHEN DIALOGUE STARTS
	get_tree().paused = true
	show()

func _input(event: InputEvent) -> void:
	if not can_press:
		return
		
	# Check if the player presses Enter or Escape
	if event.is_pressed() and not event.is_echo():
		if event is InputEventKey:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_ESCAPE:
				advance_dialogue()

func advance_dialogue() -> void:
	if dialogue_step == 0:
		# Step 1: Player pressed Enter/Esc on girlfriend's text
		can_press = false # Lock keys during the 1-second delay
		
		# Wait 1 second before showing the player's message (4th argument 'true' lets timer run while paused)
		await get_tree().create_timer(1.0, true, false, true).timeout
		
		if dialogue_label:
			dialogue_label.text = player_text
			
		dialogue_step = 1
		can_press = true # Unlock keys for the next press
		
	elif dialogue_step == 1:
		# Step 2: Player pressed Enter/Esc on player's message -> UNPAUSE GAME & HIDE
		get_tree().paused = false
		hide()
		dialogue_step = 2
