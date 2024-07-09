extends TextureRect

##Nodes from Scene##
@onready var item_slot: TextureRect = $ItemSlot/TextureRect
@onready var item_count: Label = $Addon/Label
@onready var UI: CanvasGroup = $"../../.."

func _get_drag_data(at_position) -> TextureRect: #Start Drag
	set_drag_preview(get_preview())
	return item_slot

func _can_drop_data(at_position, data) -> bool: #Test if Dropable
	if data.inv_item.item != null:
		if "Input" in name:
			return data.inv_item.item.smelt_energie >= 1
		elif "Fuel" in name:
			return data.inv_item.item.fuel_energie >= 1
		elif "Output" in name:
			return false
		elif "Helmet" in name || "Chestplate" in name || "EnergyOrbs" in name:
			return data.inv_item.item.use_type in name
		else:
			return data is TextureRect
	return false

func _drop_data(at_position, data): #Drop
	if data.get_node("../..") == self:
		return
	if data.inv_item.item != null && item_slot.inv_item.item == null: #No Item in slot
		
		#set new Item
		item_slot.inv_item = data.inv_item
		data.inv_item = InventoryItem.new()
		
		#Save change in array
		UI.edit_slots(data.get_node("../..").name, InventoryItem.new())
		UI.edit_slots(name, item_slot.inv_item)
		
		#Update Both Slots
		instantiate_item()
		data.get_node("../..").instantiate_item()
	
	elif data.inv_item.item != null && item_slot.inv_item.item != null: #Item already in Slot
		
		#Save both items
		var old_item: InventoryItem = item_slot.inv_item
		var new_item: InventoryItem = data.inv_item
		
		#Test if item can be added (count <= 100)
		if item_slot.inv_item.item.stackable && item_slot.inv_item.item == data.inv_item.item && item_slot.inv_item.count < 100: #Add same Item
			if (data.inv_item.count + item_slot.inv_item.count) <= 100: #Add item
				item_slot.inv_item.count += data.inv_item.count
				data.inv_item.item = null
			else: #Only add some, remaing goes to old slot
				var add: int = data.inv_item.count - ((item_slot.inv_item.count + data.inv_item.count) - 100)
				item_slot.inv_item.count += add
				data.inv_item.count -= add
				if data.inv_item.count <= 0:
					data.inv_item.item = null
		else: #Swoitch items
			item_slot.inv_item = new_item
			data.inv_item = old_item
		
		#Saves change in Array
		UI.edit_slots(data.get_node("../..").name, data.inv_item)
		UI.edit_slots(name, item_slot.inv_item)
		
		#Update both Slots
		instantiate_item()
		data.get_node("../..").instantiate_item()

##Get Preview for frag Image
func get_preview() -> Control:
	var preview_texture: TextureRect = TextureRect.new()
	
	preview_texture.texture = item_slot.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(60, 60)
	
	var preview: Control = Control.new()
	preview.add_child(preview_texture)
	
	return preview

##Instantiate item from Slot
func instantiate_item():
	
	var TextRect: TextureRect = get_node("ItemSlot/TextureRect")
	if TextRect.inv_item.item != null && TextRect.inv_item.count >= 1: #Ther is an item in Slot
		var item: Item = TextRect.inv_item.item
		
		#Update Slot Item Texture
		item_slot.texture = item.image
		item_slot.tooltip_text = item.name + " (" + str(TextRect.inv_item.count) + ")"
		
		#Update Slot Text
		if UI.show_name:
			item_count.text = item.name
		else:
			item_count.text = str(TextRect.inv_item.count)
		#TODO: Scale Fontsize size of item_count.size.y
	else: #No item in slot, reset all
		TextRect.texture = null
		item_slot.tooltip_text = ""
		item_count.text = ""
		TextRect.inv_item = InventoryItem.new()
