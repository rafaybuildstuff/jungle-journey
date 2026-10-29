extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0

@export var max_lives: int = 3
var current_lives: int = 3

# Make sure this points to your throwable weapon scene file name!
@export var weapon_scene: PackedScene = preload("res://scene/throwable_weapon.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead: bool = false

func _ready() -> void:
	# Automatically puts the player in the "player" group for killzones and enemies to detect
	add_to_group("player")
	current_lives = max_lives

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Handle weapon throw attack
	if Input.is_action_just_pressed("attack"):
		throw_weapon()

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

func throw_weapon() -> void:
	if weapon_scene == null:
		print("No weapon scene assigned!")
		return

	# Instantiate the weapon scene
	var weapon = weapon_scene.instantiate()
	
	# Position it at the player's current location
	weapon.global_position = global_position
	
	# Set throw direction based on which way the player sprite is facing
	var throw_dir = -1.0 if animated_sprite.flip_h else 1.0
	weapon.direction = Vector2(throw_dir, 0)
	
	# Add the weapon to the level scene tree
	get_parent().add_child(weapon)

# Called by the wolf when it touches the player (costs 1 heart instead of instant death)
func take_damage() -> void:
	if is_dead:
		return
		
	current_lives -= 1
	print("Player Lives Left: ", current_lives)
	
	if current_lives <= 0:
		die()
	else:
		# Small knockback / push upward when hit by an enemy
		velocity.y = -200.0

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

# This is called by the Killzone script for instant death (falling into hazards)
func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	# Safe deferred call to avoid physics callback crash
	call_deferred("_reload_level")

func _reload_level() -> void:
	get_tree().reload_current_scene()
