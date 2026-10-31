extends Node

# Tracks total wood collected across all scenes
var total_wood: int = 0

# Signal emitted whenever wood count changes (useful for UI updates)
signal wood_changed(new_amount: int)

func add_wood(amount: int) -> void:
	total_wood += amount
	wood_changed.emit(total_wood)
	print("Wood collected! Total: ", total_wood)
