extends Area2D

@export var broadcast_banner: CanvasLayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "player":
		# Find the banner in the scene if not assigned in Inspector
		var banner = broadcast_banner
		if not banner:
			banner = get_parent().find_child("BroadcastBanner1")
		
		if banner and banner.has_method("trigger_dialogue"):
			banner.trigger_dialogue()
		
		# Disable collision so it only pops up once
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
		
		
