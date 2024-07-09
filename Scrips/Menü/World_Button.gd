extends TextureButton

@onready var Menü: Node2D =  $"../../../../../.."

func _on_pressed():
	Menü.load_world(get_node("World_Name").text)

func delete():
	Menü.delete_world(get_node("World_Name").text)
