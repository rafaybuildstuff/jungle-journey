extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var attached_player: CharacterBody2D = null

# Stronger directional boost forces (increased horizontal push!)
@export var launch_force_up: float = -650.0
@export var launch_force_side: float = 1000.0 

@export var swing_speed: float = 0.4
var swing_timer: float = 0.0
var anim_sequence: Array[String] = ["centre", "left swing", "centre", "right swing"]
var current_anim_index: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("vine")

func _process(delta: float) -> void:
	swing_timer += delta
	if swing_timer >= swing_speed:
		swing_timer = 0.0
		current_anim_index = (current_anim_index + 1) % anim_sequence.size()
		animated_sprite.play(anim_sequence[current_anim_index])

	update_collision_position()

	if attached_player != null:
		# Snaps the player directly to the bottom tip of the vine graphic
		attached_player.global_position = global_position + get_grab_offset()
		
		if Input.is_action_just_pressed("jump"):
			release_player()

func update_collision_position() -> void:
	match animated_sprite.animation:
		"left swing":
			collision_shape.position.x = -15.0
		"right swing":
			collision_shape.position.x = 15.0
		_:
			collision_shape.position.x = 0.0

func get_grab_offset() -> Vector2:
	# REDUCED Y value from 75/80 down to 20/25 so the player's hands touch the bottom tip!
	match animated_sprite.animation:
		"left swing":
			return Vector2(-15.0, 25.0)
		"right swing":
			return Vector2(15.0, 25.0)
		_:
			return Vector2(0.0, 30.0)

func _on_body_entered(body: Node2D) -> void:
	if attached_player == null and (body.name == "player" or body.has_method("attach_to_vine")):
		attached_player = body as CharacterBody2D
		attached_player.attach_to_vine()

func release_player() -> void:
	if attached_player == null:
		return
		
	var final_velocity := Vector2.ZERO
	
	# Gives a heavy push rightwards or leftwards depending on swing direction!
	match animated_sprite.animation:
		"left swing":
			final_velocity = Vector2(-launch_force_side, launch_force_up)
		"right swing":
			final_velocity = Vector2(launch_force_side, launch_force_up)
		_:
			final_velocity = Vector2(0, launch_force_up)

	attached_player.detach_from_vine_with_velocity(final_velocity)
	attached_player = null
