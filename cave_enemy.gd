extends CharacterBody2D

@export var speed: float = 60.0
@export var max_health: int = 4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRay if has_node("WallRay") else null

var current_health: int = 4
var move_direction: int = 1 # 1 for RIGHT, -1 for LEFT
var can_take_damage: bool = true 
var turn_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	
	if animated_sprite:
		animated_sprite.flip_h = (move_direction == 1)
	
	var hitbox = get_node_or_null("Area2D")
	if hitbox and hitbox is Area2D:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if turn_cooldown > 0:
		turn_cooldown -= delta

	# 1. Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	# 2. Check for Walls
	if is_on_wall() and turn_cooldown <= 0:
		_turn_around()

	# 3. Clean Edge Check: Placed safely outside the spider's body
	if is_on_floor() and wall_ray and turn_cooldown <= 0:
		# Place the ray well ahead at the feet, pointing down
		wall_ray.position = Vector2(move_direction * 18.0, 10.0)
		wall_ray.target_position = Vector2(0.0, 16.0)
		wall_ray.force_raycast_update()
		
		# If it stops hitting the floor, turn around
		if not wall_ray.is_colliding():
			_turn_around()

	# 4. Set movement speed & apply physics
	velocity.x = move_direction * speed
	move_and_slide()

func _turn_around() -> void:
	if turn_cooldown > 0:
		return
		
	move_direction *= -1
	if animated_sprite:
		animated_sprite.flip_h = (move_direction == 1)
		
	turn_cooldown = 0.4

# --- DAMAGE METHOD ---
func take_damage(amount: int = 1) -> void:
	if not can_take_damage:
		return
		
	current_health -= amount
	
	can_take_damage = false
	var timer = get_tree().create_timer(0.2)
	timer.timeout.connect(func(): can_take_damage = true)

	if animated_sprite:
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

	if current_health <= 0:
		die()

func die() -> void:
	call_deferred("queue_free")

# --- PLAYER COLLISION METHOD ---
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scene/main_scene.tscn")
