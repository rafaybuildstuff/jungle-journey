extends Area2D

@export var wood_amount: int = 1

# Floating effect settings (you can tweak these in the Inspector!)
@export var float_amplitude: float = 4.0  # How many pixels it moves up and down
@export var float_speed: float = 5.0     # How fast it bobs

var initial_y: float
var time_passed: float = 0.0

func _ready() -> void:
	# Save the starting Y position so it floats around its placed spot
	initial_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Smoothly move up and down using a sine wave
	time_passed += delta
	position.y = initial_y + sin(time_passed * float_speed) * float_amplitude

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the player
	if body.is_in_group("player") or body.name == "Player":
		collect(body)

func collect(player: Node2D) -> void:
	# 1. Update player inventory or game manager
	if player.has_method("add_wood"):
		player.add_wood(wood_amount)
	elif GameManager:
		GameManager.add_wood(wood_amount)
	
	# 2. Disable collision immediately to prevent double collection
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 3. Play sound effect if present
	if $AudioStreamPlayer2D.stream:
		$AudioStreamPlayer2D.play()
		hide() # Hide sprite while sound finishes
		await $AudioStreamPlayer2D.finished
	
	# 4. Remove coin from scene
	queue_free()
