extends Area2D

@export var speed: float = 500.0
@export var rotation_speed: float = 15.0 # Higher number = faster spinning
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Connect collision signals safely
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# 1. Move the weapon forward in the direction it was thrown
	position += direction * speed * delta
	
	# 2. Spin the weapon node continuously in mid-air
	rotation += rotation_speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Ignore the player so it doesn't self-destruct upon throwing
	if body.is_in_group("player"):
		return
		
	# Deal damage if the body has a health/damage function
	if body.has_method("take_damage"):
		body.take_damage(1)
		
	# Destroy the weapon on impact with walls, ground, or enemies
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Optional: Handle collisions with enemy hurtboxes/areas
	if area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(1)
		queue_free()
