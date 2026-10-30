extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0

@export var max_lives: int = 3
var current_lives: int = 3

@export var weapon_scene: PackedScene = preload("res://scene/throwable_weapon.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead: bool = false
var on_vine: bool = false

func _ready() -> void:
	add_to_group("player")
	current_lives = max_lives

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# If attached to a vine, keep velocity zero and sprite forced visible
	if on_vine:
		velocity = Vector2.ZERO
		animated_sprite.visible = true
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("attack"):
		throw_weapon()

	var direction := Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * speed
		animated_sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	update_animations(direction)
	move_and_slide()

# --- VINE INTEGRATION METHODS ---
func attach_to_vine() -> void:
	on_vine = true
	velocity = Vector2.ZERO
	
	# Ensure player renders clearly on top of the vine and is visible
	z_index = 5 
	animated_sprite.visible = true
	
	if animated_sprite.sprite_frames.has_animation("hanging"):
		animated_sprite.play("hanging")
	elif animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

func detach_from_vine_with_velocity(launch_velocity: Vector2) -> void:
	on_vine = false
	velocity = launch_velocity
	
	# Reset z-index back to standard layer when letting go
	z_index = 0
	animated_sprite.visible = true

# --- WEAPON THROW ---
func throw_weapon() -> void:
	if weapon_scene == null:
		return

	var weapon = weapon_scene.instantiate()
	weapon.global_position = global_position
	var throw_dir = -1.0 if animated_sprite.flip_h else 1.0
	weapon.direction = Vector2(throw_dir, 0)
	get_parent().add_child(weapon)

func take_damage() -> void:
	if is_dead:
		return
		
	current_lives -= 1
	if current_lives <= 0:
		die()
	else:
		velocity.y = -200.0

func update_animations(direction: float) -> void:
	if not is_on_floor():
		if animated_sprite.sprite_frames.has_animation("jump"):
			animated_sprite.play("jump")
	elif direction != 0:
		if animated_sprite.sprite_frames.has_animation("run"):
			animated_sprite.play("run")
		elif animated_sprite.sprite_frames.has_animation("right"):
			animated_sprite.play("right")
	else:
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	call_deferred("_reload_level")

func _reload_level() -> void:
	get_tree().reload_current_scene()
