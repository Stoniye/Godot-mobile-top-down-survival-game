extends CanvasGroup

#region Nodes from Scene
@onready var Inventory_Window: TextureRect = $Inventory
@onready var Pause_Window: TextureRect = $Pause
@onready var Crafting_Window: TextureRect = $Crafting
@onready var Recipe_Details_Window: TextureRect = $Crafting/Recipe_Details
@onready var Open_Chest_Window: TextureRect = $Chest/Chest
@onready var Furnace_Window: TextureRect = $Furnace
@onready var Chest_Window: TextureRect = $Chest
@onready var Equipment_Window: TextureRect = $Equipment
@onready var Rocket_Window: TextureRect = $Rocket_Window
@onready var Item_Profiler_Window: TextureRect = $Item_Profiler_Window
@onready var JoyStick: Area2D = $"../JoyStick"
@onready var Hotbar_Object: Node2D = $Hotbar
@onready var Player: CharacterBody2D = $"../../Player"
@onready var scene_root: Node2D = $"../.."
@onready var Action_Panel: Node2D = $ActionPanel
@onready var Interact_Panel: Node2D = $"Interact Panel"
@onready var Only_Craftable_Toggle: TextureRect = $Crafting/OnlyCraftable/TextureRect
@onready var Save_Load: Node2D = $"../../Save_Load_Manager"
#endregion

#region Resources from Data
@onready var building_node: PackedScene = preload("res://Nodes/building.tscn")
@onready var Selected_arrow: PackedScene = preload("res://Nodes/selected_arrow.tscn")
@onready var droped_item_prefab: PackedScene = preload("res://Nodes/droped_item.tscn")
#endregion

#region Variables for Process
var SelectedSlot: int = 0
var show_name: bool
var selected_recipe: Recipe
var selected_planet: TextureButton = null
var inspecting_item: Item
var arrow: Node2D
var selected_block: int = -1
#endregion

#region Inventory List
var Inventory: Array[InventoryItem]
var Hotbar: Array[InventoryItem]
var Equipment: Array[InventoryItem]
#endregion

#region Hotbar Slots Actions
##Called when Hotbar Slot 1 is pressed
func _on_hotbar_slot_1_pressed():
	change_hotbar_slot(1)

##Called when Hotbar Slot 2 is pressed
func _on_hotbar_slot_2_pressed():
	change_hotbar_slot(2)

##Called when Hotbar Slot 3 is pressed
func _on_hotbar_slot_3_pressed():
	change_hotbar_slot(3)

##Changes the Selectet Hotbar slot
func change_hotbar_slot(newSlot: int):
	SelectedSlot = newSlot - 1
	for slot in Hotbar_Object.get_children(): #Unselect all Slots
		slot.modulate = Color("ffffff")
	#Select new Slot
	var Slot: TouchScreenButton = Hotbar_Object.get_node("Slot" + str(newSlot))
	Slot.modulate = Color("969696")
	update_Action_Panel()
#endregion

func _input(event):
	if event.is_action_pressed("Arrow_DOWN"):
		_on_action_down_pressed()
	elif event.is_action_pressed("Arrow_UP"):
		_on_action_up_pressed()
	elif event.is_action_pressed("Arrow_RIGHT"):
		_on_action_right_pressed()
	elif event.is_action_pressed("Arrow_LEFT"):
		_on_action_left_pressed()

##Toggles the Action Panel on or off
func update_Action_Panel():
	if !Inventory_Window.visible && !Pause_Window.visible && Hotbar[SelectedSlot].item != null && (Hotbar[SelectedSlot].item.use_type == "Placing" || Hotbar[SelectedSlot].item.use_type == "Mining" || Hotbar[SelectedSlot].item.use_type == "Logging"):
		Action_Panel.visible = true
	else:
		Action_Panel.visible = false

##Is called on start of Programm
func _ready():
	load_settings()
	init_Arrays()
	Inventory[0].item = load("res://Scriptable Object Recources/Items/Blocks/Interactables/Chest.tres")
	Inventory[0].count = 1
	Inventory[1].item = load("res://Scriptable Object Recources/Items/Tools/Stone/Stone_Axe.tres")
	Inventory[1].count = 1
	Inventory[1].durability = load("res://Scriptable Object Recources/Items/Tools/Stone/Stone_Axe.tres").durability
	Inventory[2].item = load("res://Scriptable Object Recources/Items/Blocks/Interactables/Crafting_Table.tres")
	Inventory[2].count = 1
	Inventory[3].item = load("res://Scriptable Object Recources/Items/Blocks/Building/Stone/Clean_Stone.tres")
	Inventory[3].count = 100
	Inventory[4].item = load("res://Scriptable Object Recources/Items/Tools/Iron/Iron_Pickaxe.tres")
	Inventory[4].count = 1
	Inventory[4].durability = load("res://Scriptable Object Recources/Items/Tools/Iron/Iron_Pickaxe.tres").durability
	Inventory[5].item = load("res://Scriptable Object Recources/Items/Blocks/Interactables/Furnace.tres")
	Inventory[5].count = 1
	Inventory[5].durability = load("res://Scriptable Object Recources/Items/Blocks/Interactables/Furnace.tres").durability
	Inventory[6].item = load("res://Scriptable Object Recources/Items/Blocks/Building/Wood/Wood_Planks.tres")
	Inventory[6].count = 10
	Inventory[7].item = load("res://Scriptable Object Recources/Items/Armor/Iron/Iron_Helmet.tres")
	Inventory[7].count = 1
	Inventory[8].item = load("res://Scriptable Object Recources/Items/Armor/Iron/Iron_Chestplate.tres")
	Inventory[8].count = 1
	Inventory[9].item = load("res://Scriptable Object Recources/Items/EnergyOrbs/Armor_Core.tres")
	Inventory[9].count = 1
	Inventory[10].item = load("res://Scriptable Object Recources/Items/EnergyOrbs/Health_Upper.tres")
	Inventory[10].count = 1
	update_hotbar()

func load_settings():
	var file: FileAccess  = FileAccess.open("user://gamedata/settings.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	show_name = (data["Gameplay"]["ItemAddon"] == "1")

##Called when Pause Button is Pressed
func toggle_pause():
	Pause_Window.visible = !Pause_Window.visible
	JoyStick.set_process_input(!Pause_Window.visible)

##Closes all UI Windows
func close_inv_UI():
	toggle_inventory(false)

##Opens alls UI Windows
func open_inv_UI():
	toggle_inventory(true)

func toggle_inventory(state: bool):
	if !Open_Chest_Window.visible && !Recipe_Details_Window.visible:
		Inventory_Window.visible = state
		Equipment_Window.visible = state && !Furnace_Window.visible && !Chest_Window.visible && !Crafting_Window.visible
		if !Inventory_Window.visible:
			Chest_Window.visible = false
			Crafting_Window.visible = false
			Furnace_Window.visible = false
		JoyStick.set_process_input(!Inventory_Window.visible)
		update_Action_Panel()
		if Inventory_Window.visible:
			update_user_stats()
			load_inv()
	else:
		Open_Chest_Window.visible = false
		Recipe_Details_Window.visible = false

##Add's an Item to Inv (Hotbar Excludet) and return if Successful
func add_item(item: InventoryItem) -> bool:
	if item.item.stackable: #If stackable search for same Items
		var i: int = search_item(item.item, 1)
		if i >= 0:
			if (Inventory[i].count + item.count) <= 100: #Add because less than 100
				Inventory[i].count += item.count
				load_inv()
				return true
			else: #Add some because more than 100, remaining gets a new Slot
				var adding: int = item.count - ((Inventory[i].count + item.count) - 100)
				Inventory[i].count += adding
				item.count -= adding
				if !create_new_slot(item):
					#Drop Item at distance, so it's not piked up instantly again
					var randX: int = 0
					while randX < 40 && randX > -40:
						randX = randi_range(-55, 55)
					var randY: int = 0
					while randY < 40 && randX > -40:
						randY = randi_range(-55, 55)
					drop_item(item, Player.position + Vector2(randX, randY)) #Drop remaining if no free slot
	return create_new_slot(item) #If no same Item, create new Slot

##Creates a new Sot in Inv and return if Successful
func create_new_slot(item: InventoryItem) -> bool:
	for i in Inventory.size():
		if Inventory[i].item == null:
			Inventory[i] = item
			load_inv()
			return true
	return false

##Called if Exit Button pressed
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menü.tscn")

##Called if Save and Exit pressed
func _on_save_and_exit_pressed():
	_save_world()
	SceneHandler.traveld = false
	_on_exit_pressed()
	
func _save_world():
	Save_Load.save_world(SceneHandler.world_name)

##Updates user Stats in Inventory Window
func update_user_stats():
	var PlayerName_Label: Label = Equipment_Window.get_node("PlayerName")
	var Health_Bar: TextureProgressBar = Equipment_Window.get_node("HealthBar")
	var Level_Bar: TextureProgressBar = Equipment_Window.get_node("LevelBar")
	PlayerName_Label.text = Player.PlayerName
	Health_Bar.value = Player.Health
	Level_Bar.value = Player.XP
	Health_Bar.max_value = Player.MaxHealth
	Level_Bar.max_value = Player.calculate_xp()
	Health_Bar.get_node("Progress").text = str(Player.Health) + "/" + str(Player.MaxHealth)
	Level_Bar.get_node("Progress").text = str(Player.XP) + "/" + str(Player.calculate_xp()) + " ---> " + str(Player.Level+1)
	Equipment_Window.get_node("ArmorPoints/Points").text = str(Player.ArmorPoints)

##Search for Item in Inv and Hotbar and returns if Successful
func search_item(item: Item, count: int) -> int:
	##TODO: If to less, seach for more and reaturn Array
	for i in Inventory.size():
		if item != null && item == Inventory[i].item && Inventory[i].count >= count:
			return i
	return -1

func search_item_array(item: Item, count: int) -> Array[int]:
	var slots: Array[int]
	for i in Inventory.size():
		if item != null && item == Inventory[i].item:
			slots.append(i)
	return slots

##Tests if Recipe is craftable and returns if craftable
func test_for_craftable(recipe) -> bool:
	for i in recipe.input_item.size():
		if search_item(recipe.input_item[i], recipe.input_count[i]) == -1:
			return false
	return true

##Returns InventoryItem class with varaibles
func create_inv_item(item: Item, count: int, durability: int) -> InventoryItem:
	var created_item: InventoryItem = InventoryItem.new()
	created_item.item = item
	created_item.count = count
	created_item.durability = durability
	return created_item

##Craft selected Recipe
func craft_item():
	if test_for_craftable(selected_recipe):
		for i in selected_recipe.input_item.size(): #Cycle trough all items and use them
			use_item(Inventory, search_item(selected_recipe.input_item[i], selected_recipe.input_count[i]), selected_recipe.input_count[i], true)
		
		add_item(create_inv_item(selected_recipe.output_item, selected_recipe.output_count, selected_recipe.output_item.durability)) #Add craftet item
		show_recipe(selected_recipe) #Update Recipe Window

##Tests if inv has a free Slot for a spezific item, returns true if free slot
func inv_free_slot(inv_item: InventoryItem = null) -> bool:
	for i in Inventory.size():
		if Inventory[i].item == null: #Slot is empty
			return true
		elif inv_item != null && inv_item.item.stackable && (Inventory[i].count + inv_item.count) <= 100: #Item can be added
			return true
	return false

##Clear Recipe Panel in Crafting Table Window
func clear_show_recipe():
	var Parent: Control = Recipe_Details_Window.get_node("InputSlots")
	var i: int = 0
	var Slot: TextureRect
	for child in Parent.get_children():
		i += 1
		Slot = Recipe_Details_Window.get_node("InputSlots/InputSlot" + str(i))
		Slot.get_node("ItemSlot/TextureRect").texture = null
		Slot.get_node("Addon/Label").text = ""

##Show the Recipe which is handed over
func show_recipe(recipe: Recipe):
	
	Recipe_Details_Window.visible = true
	clear_show_recipe()
	
	#Test if Inv has a Free slot and make the Button Red/Green
	var craft_button: TextureButton = Recipe_Details_Window.get_node("Craft")
	if inv_free_slot(create_inv_item(recipe.output_item, recipe.output_count, 0)) && test_for_craftable(recipe):
		craft_button.self_modulate = Color("95ff8d")
	else:
		craft_button.self_modulate = Color("ff9b8c")
	selected_recipe = recipe
	
	#Show Output Item
	Recipe_Details_Window.get_node("OutputSlot/ItemSlot/TextureRect").texture = recipe.output_item.image
	if show_name:
		Recipe_Details_Window.get_node("OutputSlot/Addon/Label").text = recipe.output_item.name
	else:
		Recipe_Details_Window.get_node("OutputSlot/Addon/Label").text = recipe.output_count
	
	#Show Input Items
	var Slot: TextureRect
	for i in recipe.input_item.size():
		Slot = Recipe_Details_Window.get_node("InputSlots/InputSlot" + str(i+1))
		Slot.get_node("ItemSlot/TextureRect").texture = recipe.input_item[i].image
		Slot.get_node("Addon/Label").text = str(recipe.input_count[i])

##Load furnace items in furnace Window (Fuel, Input Items, Output Items)
func load_furnace():
	var furnace: Sprite2D = get_selected_block()
	var input_slot: TextureRect = Furnace_Window.get_node("Slots/Input")
	var fuel_slot: TextureRect = Furnace_Window.get_node("Slots/Fuel")
	var output_slot: TextureRect = Furnace_Window.get_node("Slots/Output")
	
	##Load Furnace item in Slots
	input_slot.get_node("ItemSlot/TextureRect").inv_item = furnace.Items[0]
	fuel_slot.get_node("ItemSlot/TextureRect").inv_item = furnace.Items[1]
	output_slot.get_node("ItemSlot/TextureRect").inv_item = furnace.Items[2]
	
	#Update all Slots
	fuel_slot.instantiate_item()
	input_slot.instantiate_item()
	output_slot.instantiate_item()
	
	#Update Arrow
	var arr: TextureProgressBar = get_node("Furnace/TextureProgressBar")
	arr.max_value = furnace.energie_needed
	arr.value = furnace.progress

##Clears all Recipes in Furnace Window
func clear_recipes():
	var Grid_Container: GridContainer = Crafting_Window.get_node("ScrollContainer/GridContainer")
	if Crafting_Window.get_node("ScrollContainer/GridContainer/Placeholder_Bottom") != null:
		Crafting_Window.get_node("ScrollContainer/GridContainer/Placeholder_Bottom").queue_free()
	if Grid_Container.get_child_count() >= 3: #>= beacause Placeholder and prefab is ignored
		for i in Grid_Container.get_children():
			if "Recipe" in i.name:
				i.queue_free()

##Cycles through all Recipes and tests if is craftable, if not = hide it
func reload_recipes():
	var Grid_Container: GridContainer = Crafting_Window.get_node("ScrollContainer/GridContainer")
	for child in Grid_Container.get_children():
		if "Recipe" in child.name:
			if !test_for_craftable(child.slot_recipe):
				child.visible = !Only_Craftable_Toggle.visible
			else:
				child.visible = true

##Loads all Recipes from res:// and instantiates it in Crafting Window
func load_recipes():
	clear_recipes()
	
	var recipe: Recipe
	var Grid_Container: GridContainer = Crafting_Window.get_node("ScrollContainer/GridContainer")
	var recipe_prefab: TextureButton = Crafting_Window.get_node("ScrollContainer/GridContainer/Prefab")
	var placeholder: TextureRect = Crafting_Window.get_node("ScrollContainer/GridContainer/Placeholder_Top")
	var recipe_node: TextureButton
	var names: PackedStringArray = DirAccess.open("res://Scriptable Object Recources/Recipes/").get_files()
	
	for i in names.size():
		recipe = load("res://Scriptable Object Recources/Recipes/" + names[i])
		recipe_node = recipe_prefab.duplicate()
		Grid_Container.add_child(recipe_node)
		recipe_node.get_node("ItemImage").texture = recipe.output_item.image
		recipe_node.get_node("ItemName").text = recipe.output_item.name
		recipe_node.slot_recipe = recipe
		recipe_node.visible = true
		recipe_node.name = "Recipe" + str(i)
	
	placeholder = placeholder.duplicate()
	Grid_Container.add_child(placeholder)
	placeholder.name = "Placeholder_Bottom"
	
	reload_recipes()

##Load items from Array in Slots
func load_inv():
	
	#Load inv
	var Grid = Inventory_Window.get_node("InventoryGrid")
	var i: int = 0
	for slot in Grid.get_children():
		slot.item_slot.inv_item = Inventory[i]
		i+=1
	
	#Load hotbar
	Grid = Equipment_Window.get_node("HotbarGrid")
	i = 0
	for slot in Grid.get_children():
		slot.item_slot.inv_item = Hotbar[i]
		i+=1
	
	#Load Equipment
	Grid = Equipment_Window.get_node("EquipmentGrid")
	i = 0
	for slot in Grid.get_children():
		slot.item_slot.inv_item = Equipment[i]
		i+=1
	
	update_inv()

##Instatiate all Items in Slots
func update_inv():
	
	#update inv
	var Grid = Inventory_Window.get_node("InventoryGrid")
	for slot in Grid.get_children():
		slot.instantiate_item()
	
	#update Hotbar
	Grid = Equipment_Window.get_node("HotbarGrid")
	for slot in Grid.get_children():
		slot.instantiate_item()
	
	#update Equipment
	Grid = Equipment_Window.get_node("EquipmentGrid")
	for slot in Grid.get_children():
		slot.instantiate_item()
	
	update_hotbar()
	manage_Equipment()

##Initialise Arrays for process
func init_Arrays():
	for i in 34:
		Inventory.append(InventoryItem.new())
	for i in 3:
		Hotbar.append(InventoryItem.new())
	for i in 4:
		Equipment.append(InventoryItem.new())

##Update hotbar (not hotbar in Inv Window (use update_inv()))
func update_hotbar():
	var HotbarObj = $Hotbar
	var i: int = 0
	for child in HotbarObj.get_children():
		i = int(child.name.split("Slot")[1]) - 1 #Get Slot position
		
		#Update Slot Texture
		if Hotbar[i].item != null:
			child.get_node("TextureRect").texture = Hotbar[i].item.image
		else:
			child.get_node("TextureRect").texture = null
		
		#Update Item in Slot
		child.get_node("TextureRect").inv_item = Hotbar[i]

##Edid arrays with changes in Spezific Array
func edit_slots(slot_name: String, InvItem: InventoryItem):
	var slot: int
	if "Hotbar" in slot_name:
		slot = int(slot_name.split("HotbarSlot")[1]) - 1
		Hotbar[slot] = InvItem
		update_hotbar()
		change_hotbar_slot(SelectedSlot + 1)
	elif "Helmet" in slot_name:
		Equipment[0] = InvItem
		manage_Equipment()
	elif "Chestplate" in slot_name:
		Equipment[2] = InvItem
		manage_Equipment()
	elif "EnergyOrb" in slot_name:
		slot = int(slot_name.split("EnergyOrb")[1]) - 1
		Equipment[slot] = InvItem
		manage_Equipment()
	elif "Inventory" in slot_name:
		slot = int(slot_name.split("InventorySlot")[1]) - 1
		Inventory[slot] = InvItem
	elif "Input" in slot_name || "Output" in slot_name || "Fuel" in slot_name:
		var furnace = get_selected_block()
		furnace.Items[0] = get_node("Furnace/Slots/Input/ItemSlot/TextureRect").inv_item
		furnace.Items[1] = get_node("Furnace/Slots/Fuel/ItemSlot/TextureRect").inv_item
		furnace.Items[2] = get_node("Furnace/Slots/Output/ItemSlot/TextureRect").inv_item
		furnace.test_for_smelting()
	elif  "TransferToChest" in slot_name:
		var Chest: Sprite2D = get_selected_block()
		var transfere_item: TextureRect = Chest_Window.get_node("Slots/TransferToChestSlot/ItemSlot/TextureRect")
		for inv in Chest.chest_inv.size():
			if Chest.chest_inv[inv].item == null:
				for i in Chest.chest_inv.size(): #Seach for same Item
					if Chest.chest_inv[i].item == transfere_item.inv_item.item && (Chest.chest_inv[i].count + transfere_item.inv_item.count) <= 100:
						Chest.chest_inv[i].count += transfere_item.inv_item.count
						transfere_item.inv_item = InventoryItem.new()
						Chest_Window.get_node("Slots/TransferToChestSlot").instantiate_item()
						load_Chest()
						return
				for i in Chest.chest_inv.size(): #Seach for new Slot
					if Chest.chest_inv[i].item == null:
						Chest.chest_inv[i] = transfere_item.inv_item
						transfere_item.inv_item = InventoryItem.new()
						Chest_Window.get_node("Slots/TransferToChestSlot").instantiate_item()
						load_Chest()
						return
		if add_item(transfere_item.inv_item):
			transfere_item.inv_item = InventoryItem.new()
			Chest_Window.get_node("Slots/TransferToInvSlot").instantiate_item()
	elif "Chest" in slot_name && !"plate" in slot_name:
		slot = int(slot_name.split("ChestSlot")[1]) - 1
		get_selected_block().chest_inv[slot] = InvItem
	elif "TransferToInv" in slot_name:
		var transfere_item: TextureRect = Chest_Window.get_node("Slots/TransferToInvSlot/ItemSlot/TextureRect")
		if add_item(transfere_item.inv_item):
			transfere_item.inv_item = InventoryItem.new()
			Chest_Window.get_node("Slots/TransferToInvSlot").instantiate_item()
		return

func manage_Equipment():
	var ArmorPoints: int = 0
	var MaxHelth: int = 100
	if Equipment[0].item != null:
		ArmorPoints += Equipment[0].item.damage_entity
	if Equipment[2].item != null:
		ArmorPoints += Equipment[2].item.damage_entity
	
	var Orb1: Item = Equipment[1].item
	var Orb2: Item = Equipment[3].item
	if Orb1 != null:
		if Orb1.damage_block == 1:
			ArmorPoints += Orb1.damage_entity
		elif Orb1.damage_block == 2:
			MaxHelth += Orb1.damage_entity
	if Orb2 != null:
		if Orb2.damage_block == 1:
			ArmorPoints += Orb2.damage_entity
		elif Orb2.damage_block == 2:
			MaxHelth += Orb2.damage_entity
	
	Player.ArmorPoints = ArmorPoints
	Player.MaxHealth = MaxHelth
	Player.Health = min(Player.Health, Player.MaxHealth)
	update_user_stats()

##Clamps handed over <num> to <clamp> number and returns that
func clamp_to_int(num: float, clamp_to: int) -> int:
	var zahl: int = int(num)
	var rest = zahl % clamp_to
	var gerundete_zahl = zahl - rest
	if rest > (clamp_to/2):
		gerundete_zahl += clamp_to
	elif rest < -(clamp_to/2):
		gerundete_zahl -= clamp_to
	return gerundete_zahl

##Use Item in <inv> Array, returns if successful
func use_item(inv: Array[InventoryItem], slot: int, quantity: int, use: bool) -> bool:
	if inv[slot].item.use_type == "Placing" || inv[slot].item.use_type == "Item": #Quantity has to be degreased
		if inv[slot].count >= quantity:
			if use:
				inv[slot].count -= quantity
				if inv[slot].count <= 0:
					inv[slot] = InventoryItem.new()
					update_Action_Panel()
				update_inv()
				update_Action_Panel()
			return true
	elif (inv[slot].item.use_type == "Mining" || inv[slot].item.use_type == "Logging"): #Duarbility has to be degreased
		if inv[slot].durability >= quantity:
			if use:
				inv[slot].durability -= quantity
				if inv[slot].durability <= 0:
					inv[slot] = InventoryItem.new()
					update_Action_Panel()
				update_inv()
				update_Action_Panel()
			return true
	return false

func search_and_use_Item(item: Item, quantitity: int) -> bool:
	var slots: Array[int] = search_item_array(item, quantitity)
	for i in slots:
		if Inventory[slots[i]].item != null && Inventory[slots[i]].count <= quantitity:
			return use_item(Inventory, slots[i], quantitity, true)
		elif Inventory[slots[i]].item != null:
			quantitity -= Inventory[slots[i]].count
			use_item(Inventory, slots[i], Inventory[slots[i]].count, true)
	return false

##Drop item on spezific position
func drop_item(inv_item: InventoryItem, pos: Vector2):
	
	#Instantiate droped Item
	var Obj: Node2D = droped_item_prefab.instantiate()
	scene_root.add_child(Obj)
	
	#Save Item in Droped Item, update Texture and set position
	Obj.get_node("Item").inv_item = InventoryItem.new()
	Obj.get_node("Item").inv_item = inv_item
	Obj.get_node("ItemImage").texture = inv_item.item.image
	Obj.position = pos
	Obj.name = "Droped_Item"

func place_item(item: Item, health: int, pos: Vector2) -> Sprite2D:
	
	add_tokens(10)
	
	#Instantiate Item in Scene, Texture and other needet things
	var Obj: Sprite2D = building_node.instantiate()
	scene_root.add_child.call_deferred(Obj)
	Obj.position = pos
	Obj.texture = item.image
	Obj.get_node("Item").inv_item = InventoryItem.new()
	Obj.get_node("Item").inv_item.item = item
	Obj.get_node("Item").inv_item.durability = health
	
	#Add needed Area2D if its interactable
	if Obj.get_node("Item").inv_item.item.name == "Crafting Table":
		add_area(Obj, "Crafting_Table")
	elif Obj.get_node("Item").inv_item.item.name == "Furnace":
		add_area(Obj, "Furnace")
		Obj.set_script(load("res://Scrips/Furnace/Furnace.gd"))
		Obj.init_array()
		Obj.test_for_smelting()
	elif Obj.get_node("Item").inv_item.item.name == "Chest":
		add_area(Obj, "Chest")
		Obj.set_script(load("res://Scrips/Chest.gd"))
		Obj.init_Array()
	
	Obj.add_to_group("Saveable")
	return Obj

##Place block whitch is selected in Hotbar
func place_selected_item(pos: Vector2):
	if Hotbar[SelectedSlot].item.use_type == "Placing" && use_item(Hotbar, SelectedSlot, 1, false):
		place_item(Hotbar[SelectedSlot].item, load(Hotbar[SelectedSlot].item.resource_path).durability, pos)
		use_item(Hotbar, SelectedSlot, 1, true)

##Add an area to an interactable object, with handed over groupe name
func add_area(Obj: Node2D, groupe: String):
	var area: Area2D = Area2D.new()
	var coll: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 75
	Obj.add_child(area)
	area.add_child(coll)
	coll.shape = shape
	area.add_to_group("Interactable")
	area.add_to_group(groupe)
	area.name = "Area2D"

##Mine a spezific block
func mine_block(block: Node2D, damage: int):
	
	block.get_node("Item").inv_item.durability -= damage
	
	if block.get_node("Item").inv_item.durability <= 0:
		drop_item(create_inv_item(block.get_node("Item").inv_item.item, 1, 0), block.position + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
		
		#Dropping Items of object if there are some
		if block.get_node("Area2D") != null:
			if block.get_node("Area2D").is_in_group("Furnace"):
				if block.input_inv_item.count >= 1:
					drop_item(block.input_inv_item, block.position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))
				if block.fuel_inv_item.count >= 1:
					drop_item(block.fuel_inv_item, block.position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))
				if block.output_inv_item.count >= 1:
					drop_item(block.output_inv_item, block.position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))
			elif block.get_node("Area2D").is_in_group("Chest"):
				var inv: Array[InventoryItem] = block.chest_inv
				for i in inv.size():
					if inv[i].item != null:
						drop_item(inv[i], block.position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))
		
		#Destroy block
		block.queue_free()

##Action button pressed (Up, Down, Left, Right)
func action_Button(RayCast: RayCast2D, offset_x: int, offset_y: int):
	if Hotbar[SelectedSlot].item != null && Hotbar[SelectedSlot].item.use_type == "Placing" && !RayCast.is_colliding(): #Place item/Blcck
		place_selected_item(Vector2(clamp_to_int(Player.position.x + offset_x, 32), clamp_to_int(Player.position.y + offset_y, 16)))
	elif RayCast.is_colliding() && use_item(Hotbar, SelectedSlot, 1, false): #Use item
		if RayCast.get_collider().get_node("..").get_node("Item") != null && RayCast.get_collider().get_node("..").get_node("Item").inv_item.item.itemtype_for_interacting == Hotbar[SelectedSlot].item.use_type:
			mine_block(RayCast.get_collider().get_node(".."), Hotbar[SelectedSlot].item.damage_block)
			use_item(Hotbar, SelectedSlot, 1, true)

##Called when Action Button Arrow UP is pressed
func _on_action_up_pressed():
	action_Button(Player.RayCast_UP, 0, -32)

##Called when Action Button Arrow RIGHT is pressed
func _on_action_right_pressed():
	action_Button(Player.RayCast_RIGHT, 41, 0)

##Called when Action Button Arrow LEFT is pressed
func _on_action_left_pressed():
	action_Button(Player.RayCast_LEFT, -41, 0)

##Called when Action Button Arrow DOWN is pressed
func _on_action_down_pressed():
	action_Button(Player.RayCast_DOWN, 0, 32)

##Called when Action Button Arrow UP is pressed
func _on_interact_button_pressed():
	if Inventory_Window.visible == false:
		var areas: Array[Area2D] = get_interactable_nearby()
		if areas.size() > selected_block:
			if areas[selected_block].is_in_group("Crafting_Table"):
				toggle_crafting_window()
			elif areas[selected_block].is_in_group("Furnace"):
				toggle_furnace_window()
			elif areas[selected_block].is_in_group("Chest"):
				toggle_chest_window()
			elif areas[selected_block].is_in_group("Rocket"):
				toggle_rocket_window()
		else :
			update_interact_button()

func fly_to_planet():
	var Areas: Array[Area2D] = scene_root.get_node("Rocket/Area2D").get_overlapping_areas()
	Save_Load.save_world(SceneHandler.world_name)
	##TODO: Play fly Animation
	SceneHandler.traveld = true
	get_tree().change_scene_to_file("res://Scenes/Planets/" + selected_planet.name + ".tscn")

func toggle_rocket_window():
	Rocket_Window.visible = !Rocket_Window.visible
	Rocket_Window.get_node("ScrollContainer/Scrollable/SelectedPlanet").visible = false
	Rocket_Window.get_node("Tab").visible = false
	##TODO: Horizontal Scroll auf 148 und Vertical auf 166

##Called when on Interact button, left got pressed
func _on_rotate_left_pressed():
	rotate_selected(1)

##Called when on Interact button, left got pressed
func _on_rotate_right_pressed():
	rotate_selected(-1)

##Rotates through all Interactable blocks nearby, and selects next/previous one
func rotate_selected(rotate_to: int):
	var areas: Array[Area2D] = get_interactable_nearby()
	
	if (selected_block + rotate_to) <= -1: #Start at end of Array
		selected_block = (areas.size() - 1)
	elif areas.size() <= (selected_block + rotate_to): #Start at begin of Array
		selected_block = 0
	else:
		selected_block += rotate_to #Rotate to next one
	
	#Select new Block
	var block: Sprite2D = get_selected_block()
	Interact_Panel.get_node("InteractButton/TextureRect").texture = block.texture
	if arrow != null: #Delte old arrow if there
		arrow.queue_free()
	arrow = Selected_arrow.instantiate()
	arrow.name = "Arrow"
	scene_root.add_child.call_deferred(arrow)
	arrow.position = block.position

func get_interactable_nearby() -> Array[Area2D]:
	var all_areas: Array[Area2D] = Player.FullBody_Area.get_overlapping_areas()
	var areas: Array[Area2D]
	for a in all_areas: #Get count of Interactalbes nearby
		if a.is_in_group("Interactable"):
			areas.append(a)
	return areas

##Update Interact button, called when area entered or left
func update_interact_button():
	var lenght: int = get_interactable_nearby().size()
	
	if lenght <= 0: #No interactable nearby
		Interact_Panel.visible = false
		selected_block = -1 #Reset selected block
		if arrow != null:
			arrow.queue_free()
		return
	else: #Interactable nearby
		Interact_Panel.visible = true
		if lenght == 1: #Freshly entered, rotate to interactable 0
			rotate_selected(1)

##Is called when Area of player entered
func player_area_entered(area: Area2D):
	if area.is_in_group("Interactable"):
		update_interact_button()

##Is called when Area of player exited
func player_area_exited(area: Area2D):
	if area.is_in_group("Interactable"):
		update_interact_button()

##Is called when Area of players feet entered
func feed_area_entered(area: Area2D):
	if area.is_in_group("Droped_Item"):
		var item: InventoryItem = area.get_node("../Item").inv_item
		if add_item(item):
			area.get_node("..").queue_free()

##Toggle crafting window (show/hide)
func toggle_crafting_window():
	Crafting_Window.visible = !Crafting_Window.visible
	toggle_inventory(!Inventory_Window.visible)
	if Crafting_Window.visible:
		load_recipes()

##Toggle furnace window (show/hide)
func toggle_furnace_window():
	Furnace_Window.visible = !Furnace_Window.visible
	toggle_inventory(!Inventory_Window.visible)
	if Furnace_Window.visible:
		load_furnace()

##Returns Sprite2D of selected interactable block
func get_selected_block() -> Sprite2D:
	var areas: Array[Area2D] = get_interactable_nearby()
	return areas[selected_block].get_node("..")

##Toggle chest window (show/hide)
func toggle_chest_window():
	Chest_Window.visible = !Chest_Window.visible
	toggle_inventory(!Inventory_Window.visible)
	if Chest_Window.visible:
		var ToChestSlot: TextureRect = Chest_Window.get_node("Slots/TransferToChestSlot")
		var ToInvSlot: TextureRect = Chest_Window.get_node("Slots/TransferToInvSlot")
		ToChestSlot.get_node("ItemSlot/TextureRect").inv_item = InventoryItem.new()
		ToChestSlot.instantiate_item()
		ToInvSlot.get_node("ItemSlot/TextureRect").inv_item = InventoryItem.new()
		ToInvSlot.instantiate_item()

##Load Items in Selected Chest to Chest Window
func load_Chest():
	var Chest: Sprite2D = get_selected_block()
	var slot: TextureRect
	for i in Chest.chest_inv.size():
		slot = Open_Chest_Window.get_node("ChestSlot" + str(i+1) + "/ItemSlot/TextureRect")
		slot.inv_item = InventoryItem.new()
		if Chest.chest_inv[i].item != null:
			slot.inv_item = Chest.chest_inv[i]
			slot.get_node("../..").instantiate_item()

##Opens Chest Window (over the Inv, when chest is opend)
func open_chest():
	Open_Chest_Window.visible = !Open_Chest_Window.visible
	if Open_Chest_Window.visible:
		load_Chest()

##Toggle Only Craftable button in Crafting Table Window
func toggle_only_craftable():
	Only_Craftable_Toggle.visible = !Only_Craftable_Toggle.visible
	reload_recipes()

func toggele_inspector():
	Item_Profiler_Window.visible = !Item_Profiler_Window.visible
	Item_Profiler_Window.get_node("ItemInfo").visible = true
	Item_Profiler_Window.get_node("ItemRecipe").visible = false

func toggle_inspecting_recipe():
	Item_Profiler_Window.get_node("ItemRecipe").visible = !Item_Profiler_Window.get_node("ItemRecipe").visible
	Item_Profiler_Window.get_node("ItemInfo").visible = !Item_Profiler_Window.get_node("ItemRecipe").visible
	
	if Item_Profiler_Window.get_node("ItemRecipe").visible:
		show_inspecting_recipe()

func show_inspecting_recipe():
	
	var recipe: Recipe = find_recipe(inspecting_item)
	
	clear_inspecting_recipe()
	
	#Show Output Item
	Item_Profiler_Window.get_node("ItemRecipe/OutputSlot/ItemSlot/TextureRect").texture = recipe.output_item.image
	if show_name:
		Item_Profiler_Window.get_node("ItemRecipe/OutputSlot/Addon/Label").text = recipe.output_item.name
	else:
		Item_Profiler_Window.get_node("ItemRecipe/OutputSlot/Addon/Label").text = recipe.output_count
	
	#Show Input Items
	var Slot: TextureRect
	for i in recipe.input_item.size():
		Slot = Item_Profiler_Window.get_node("ItemRecipe/InputSlots/InputSlot" + str(i+1))
		Slot.get_node("ItemSlot/TextureRect").texture = recipe.input_item[i].image
		Slot.get_node("Addon/Label").text = str(recipe.input_count[i])

func clear_inspecting_recipe():
	pass

func find_recipe(item: Item) -> Recipe:
	var names: PackedStringArray = DirAccess.open("res://Scriptable Object Recources/Recipes/").get_files()
	
	for i in names.size():
		if load("res://Scriptable Object Recources/Recipes/" + names[i]).output_item.name == item.name:
			return load("res://Scriptable Object Recources/Recipes/" + names[i])
	return null

func inspect_item(item: Item):
	toggele_inspector()
	
	inspecting_item = item
	
	#UI
	Item_Profiler_Window.get_node("ItemInfo/ItemSlot/Item").texture = item.image
	Item_Profiler_Window.get_node("ItemInfo/ItemTitle/ItemName").text = item.name
	
	#Properties
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/UseType").text = "Use Type: " + item.use_type
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/InteractType").text = "Interact Type: " + item.itemtype_for_interacting
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/EntityDamage").text = "Entity Damage: " + str(item.damage_entity)
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/BlockDamage").text = "Block Damage: " + str(item.damage_block)
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/Durability").text = "Durability: " + str(item.durability)
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/Stackable").text = "Stackable: " + str(item.stackable)
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/SmeltEnergie").text = "Smelt Energie: " + str(item.smelt_energie)
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/SmeltItem/ItemSlot/Item").texture = null
	Item_Profiler_Window.get_node("ItemInfo/ItemProperties/FuelEnergie").text = "Fuel Energie: " + str(item.fuel_energie)
	Item_Profiler_Window.get_node("ItemInfo/ItemDescription/Description").text = item.description
	
	#Overwrite Values
	if item.use_type == "Helmet" || item.use_type == "Chestplate":
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/EntityDamage").text = "Protection: " + str(item.damage_entity)
	elif item.use_type == "Placing":
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/Durability").text = "Helth: " + str(item.durability)
	
	if item.smelt_item != null:
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/SmeltItem/ItemSlot/Item").texture = item.smelt_item.image
	
	if item.itemtype_for_interacting == "":
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/InteractType").text = "Interact Type: /"
	if item.damage_entity <= 0:
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/EntityDamage").text = "Entity Damage: /"
	if item.damage_block <= 0:
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/BlockDamage").text = "Block Damage: /"
	if item.durability <= 0:
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/Durability").text = "Durability: /"
	if item.smelt_energie <= 0:
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/SmeltEnergie").text = "Smelt Energie: /"
	if item.fuel_energie <= 0:
		Item_Profiler_Window.get_node("ItemInfo/ItemProperties/FuelEnergie").text = "Fuel Energie: /"
	
	Item_Profiler_Window.get_node("ItemInfo/ShowRecipe").visible = false
	
	if find_recipe(item) != null:
			Item_Profiler_Window.get_node("ItemInfo/ShowRecipe").visible = true

func inspect_smeltin_item():
	if inspecting_item.smelt_item != null:
		inspect_item(inspecting_item.smelt_item)
		toggele_inspector()

func show_inspectin_recipe():
	toggle_inspecting_recipe()

func add_tokens(number: int):
	var file: FileAccess  = FileAccess.open("user://gamedata/inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var Tokens: int = int(data["Money"]["Tok"])
	Tokens += number
	data["Money"]["Tok"] = str(Tokens)
	file = FileAccess.open("user://gamedata/inventory.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
