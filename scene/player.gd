extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump using Input Map actions ("jump")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction (-1 for left, 1 for right) using Input Map actions
	var direction := Input.get_axis("left", "right")

	# Handle movement and horizontal animations
	if direction:
		velocity.x = direction * speed
		
		# Flip sprite or play left/right animations based on direction
		if direction > 0:
			animated_sprite.play("right")
		else:
			animated_sprite.play("left")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
		# Play idle when standing still on the floor
		if is_on_floor():
			animated_sprite.play("idle")

	# Play jump animation when in the air
	if not is_on_floor():
		animated_sprite.play("jump")

	# Apply movement
	move_and_slide()


func _on_teleport_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
