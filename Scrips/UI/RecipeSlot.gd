extends TextureButton

@onready var UI: CanvasGroup = $"../../../.."
var slot_recipe: Recipe

func _on_pressed():
	UI.show_recipe(slot_recipe)
