extends CharacterBody2D

@export var max_health: int = 5
var current_health: int = max_health

@export var speed: float = 100.0          
@export var chase_speed: float = 180.0    
@export var jump_force: float = -380.0    

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var edge_detector: RayCast2D = $RayCast2D # Make sure your RayCast2D node is named "RayCast2D"

var player: CharacterBody2D = null
var is_jumping: bool = false
var patrol_direction: int = 1 
var damage_cooldown: float = 0.0

func _ready() -> void:
	current_health = max_health
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta: float) -> void:
	if damage_cooldown > 0:
		damage_cooldown -= delta

	# 1. Gravity & Floor Detection
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if is_jumping and velocity.y >= 0:
			is_jumping = false

	# 2. State Logic
	if player != null:
		if is_on_floor() and not is_jumping:
			jump_at_player()
	else:
		if is_on_floor() and not is_jumping:
			patrol()

	# 3. Collision Damage to Player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage") and damage_cooldown <= 0:
				collider.take_damage()
				damage_cooldown = 1.0

	move_and_slide()

# --- PATROL LOGIC WITH EDGE DETECTION ---
func patrol() -> void:
	if animated_sprite.sprite_frames.has_animation("run"):
		animated_sprite.play("run")
	elif animated_sprite.sprite_frames.has_animation("walk"):
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

	animated_sprite.flip_h = (patrol_direction > 0)

	# Update RayCast2D X position to match walking direction so it checks ahead for cliffs
	edge_detector.target_position.x = abs(edge_detector.target_position.x) * patrol_direction

	# Turn around if hitting a wall OR if the edge detector is no longer touching the floor
	if is_on_wall() or not edge_detector.is_colliding():
		patrol_direction *= -1

	velocity.x = patrol_direction * speed

# --- JUMP / CHASE LOGIC ---
func jump_at_player() -> void:
	if player == null:
		return
		
	is_jumping = true
	if animated_sprite.sprite_frames.has_animation("jump"):
		animated_sprite.play("jump")
	
	velocity.y = jump_force
	
	var dir_to_player = sign(player.global_position.x - global_position.x)
	if dir_to_player == 0:
		dir_to_player = 1.0
		
	velocity.x = dir_to_player * chase_speed
	animated_sprite.flip_h = (dir_to_player > 0)

# --- SIGNALS & HEALTH ---
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Wolf Health: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
