extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead: bool = false

func _ready() -> void:
	# Automatically puts the player in the "player" group for the killzone to detect
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction (-1, 0, 1)
	var direction := Input.get_axis("left", "right")

	# Horizontal movement
	if direction != 0:
		velocity.x = direction * speed
		
		# Flip sprite visually (instead of needing separate left/right animation names)
		animated_sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Handle Animations
	update_animations(direction)

	# Apply movement
	move_and_slide()

func update_animations(direction: float) -> void:
	if not is_on_floor():
		# Air animation
		if animated_sprite.sprite_frames.has_animation("jump"):
			animated_sprite.play("jump")
	elif direction != 0:
		# Run/walk animation (plays "right" or "run" depending on what you named it)
		if animated_sprite.sprite_frames.has_animation("run"):
			animated_sprite.play("run")
		elif animated_sprite.sprite_frames.has_animation("right"):
			animated_sprite.play("right")
	else:
		# Idle animation
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

# Optional: Call this from the killzone if you want a die sound/animation before scene reloads
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
