extends TextureRect
@onready var UI: CanvasGroup = $"../.."

func _can_drop_data(at_position, data) -> bool: #Test if Dropable
	return data is TextureRect

func _drop_data(at_position, data): #Drop
	UI.inspect_item(data.inv_item.item)
