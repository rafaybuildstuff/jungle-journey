extends Area2D

@export var death_delay: float = 0.3

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Disable collision monitoring safely to prevent double-triggering
		set_deferred("monitoring", false)
		
		if body.has_method("die"):
			body.die()
		else:
			# If player doesn't have die(), reload safely
			call_deferred("reload_scene")

func reload_scene() -> void:
	get_tree().reload_current_scene()
