extends TextureButton

@onready var Selected_prefab: TextureRect = $"../SelectedPlanet"
@onready var Tab: TextureRect = $"../../../Tab"
@onready var UI: CanvasGroup = $"../../../.."

@export var distance: float
@export var plante_size: float

func _on_pressed():
	Selected_prefab.position = Vector2(position.x - 5, position.y - 5)
	Selected_prefab.size = Vector2(size.x + 10, size.y + 10)
	Selected_prefab.visible = true
	UI.selected_planet = self
	Tab.get_node("PlanetImage").texture = texture_normal
	Tab.get_node("PlanetName").text = name
	Tab.get_node("PlanetDistance").text = "Dis: " + str(distance) + " Mio km"
	Tab.get_node("PlanetSize").text = "Size: " + str(plante_size) + "k km"
	Tab.visible = true
	if name == get_tree().current_scene.name:
		Tab.get_node("Travel").visible = false
	else:
		Tab.get_node("Travel").visible = true
