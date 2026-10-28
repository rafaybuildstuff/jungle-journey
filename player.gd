extends CharacterBody2D

# --- MOVEMENT SETTINGS ---
@export_group("Movement")
@export var walk_speed: float = 220.0
@export var run_speed: float = 340.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1600.0

# --- JUMP & GRAVITY SETTINGS ---
@export_group("Jumping & Gravity")
@export var jump_force: float = -420.0
@export var gravity: float = 1100.0
@export var fall_gravity_multiplier: float = 1.4  # Falls faster for snappier jump feel
@export var coyote_time: float = 0.15              # Time (sec) allowed to jump after leaving a ledge
@export var jump_buffer_time: float = 0.12        # Time (sec) jump input is remembered before landing

# --- INTERNAL TIMER TRACKERS ---
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. Update Timers
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

	# 2. Buffer Jump Input
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	# 3. Apply Gravity (Higher gravity when falling makes jumps feel snappy)
	if not is_on_floor():
		var current_gravity := gravity
		if velocity.y > 0:
			current_gravity *= fall_gravity_multiplier
		velocity.y += current_gravity * delta

	# 4. Handle Jumping (using Coyote Time & Jump Buffer)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# Variable jump height: releasing jump button early cuts jump short
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.45

	# 5. Speed Selection (Hold Shift to run)
	var current_target_speed := walk_speed
	if Input.is_action_pressed("ui_shift"): # Ensure "ui_shift" or Shift key is mapped, or replace with custom run action
		current_target_speed = run_speed

	# 6. Horizontal Movement with Smooth Inertia
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		# Accelerate towards input direction
		velocity.x = move_toward(velocity.x, direction * current_target_speed, acceleration * delta)
	else:
		# Decelerate to a smooth stop
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	# 7. Apply Movement
	move_and_slide()
