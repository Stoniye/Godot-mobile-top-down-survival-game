extends Node2D

##Nodes from Scene##
@onready var Menü_scene: Control = $"Canvas/Menü_Scene"
@onready var World_Manager_scene: Control = $Canvas/World_Manager_Scene
@onready var Shop_scene: Control = $Canvas/Shop_Scene
@onready var Chest_Info: TextureRect = Shop_scene.get_node("Chests_Scene/ChestInfo")
@onready var Open_Chest: TextureRect = Shop_scene.get_node("Chests_Scene/OpenChest")
@onready var Settings_Scene: Control = $Canvas/Settings_Scene

##Const##
const data_path = "user://gamedata/"
const world_path = data_path + "Worlds/"
const link_discord = "https://discord.com/invite/fveUcsHGA2"
const link_X_Resilentia = "https://twitter.com/ResilentiaGame"
const link_X_Eternity = "https://twitter.com/Eternitytain"

var Tokens: int = 0
var Coins: int = 0
var Plurana: int = 0

var codes: Dictionary = {
	"32aR-hW8h-kZ2s-KO8F":{
		"CosmeticType":{
			"0": "Title",
			"1": "Title",
			"2": "Title",
			"3": "Chest",
			"4": "Chest",
			"5": "Chest",
			"6": "Chest",
			"7": "Chest",
			"8": "Money",
			"9": "Money",
			"10": "Money",
		},
		"Path":{
			"0": "Special/Admin.tres",
			"1": "Special/Developer.tres",
			"2": "Special/OG.tres",
			"3": "Fre#99999",
			"4": "1#99999",
			"5": "2#99999",
			"6": "3#99999",
			"7": "Pre#99999",
			"8": "Tok#9999999",
			"9": "Coi#9999999",
			"10": "Plu#9999999"
		}
	},
	"habe-dich-ganz-lieb":{
		"CosmeticType":{
			"0": "Title",
			"1": "Hat",
			"2": "Title",
			"3": "Pet",
			"4": "Title"
		},
		"Path":{
			"0": "Special/Admin's_Girl.tres",
			"1": "Special/Circling_Hearts.tres",
			"2": "Special/Beautiful_Girl.tres",
			"3": "Special/Floating_Heart.tres",
			"4": "Special/Angel.tres"
		}
	}}

func _ready():
	if !DirAccess.dir_exists_absolute("user://gamedata/Worlds"):
		DirAccess.make_dir_recursive_absolute("user://gamedata/Worlds")
	if !FileAccess.file_exists(data_path + "settings.save"):
		var file: FileAccess = FileAccess.open(data_path + "settings.save", FileAccess.WRITE)
		var data: Dictionary = {
			"Gameplay":{
				"ItemAddon": "0"
			}
		}
		file.store_string(JSON.stringify(data))
		file.close()
	if !FileAccess.file_exists(data_path + "inventory.save"):
		var file: FileAccess = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
		var data: Dictionary = {
			
			"Money":{
				"Tok": "0",
				"Coi": "0",
				"Plu": "0"
			},
			"Chests":{
				"Fre": "0",
				"1": "0",
				"2": "0",
				"3": "0",
				"Pre": "0"
			},
			"Cosmetics":{
				"Animal": {
				},
				"Backback": {
				},
				"Footsteps": {
				},
				"Hat": {
				},
				"Inactivity": {
				},
				"Item": {
				},
				"Money": {
				},
				"Pet": {
				},
				"Skin": {
				},
				"Title": {
				}
			}
		}
		file.store_string(JSON.stringify(data))
		file.close()
	load_settings()

func load_settings():
	var file: FileAccess  = FileAccess.open(data_path + "settings.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	Settings_Scene.get_node("Gameplay_Scene/ScrollContainer/VBoxContainer/ItemAddon/CheckSlider/Checked").visible = (data["Gameplay"]["ItemAddon"] == "1")

##Menü Buttons funtion##
func _on_start_button_pressed():
	var dir: DirAccess = DirAccess.open(world_path)
	if dir.get_files().size() >= 1:
		change_scene(2)
	else:
		change_scene(3)

func change_scene(num: int):
	World_Manager_scene.visible = false
	Menü_scene.visible = false
	Shop_scene.visible = false
	Settings_Scene.visible = false
	World_Manager_scene.get_node("Create_World").visible = false
	World_Manager_scene.get_node("Load_World").visible = false
	if num == 1:
		Menü_scene.visible = true
	elif num == 2:
		World_Manager_scene.visible = true
		World_Manager_scene.get_node("Load_World").visible = true
		load_saved_worlds()
	elif num == 3:
		World_Manager_scene.visible = true
		World_Manager_scene.get_node("Create_World").visible = true
	elif num == 4:
		load_money()
		Shop_scene.visible = true
		change_selector(1)
	elif num == 5:
		Settings_Scene.visible = true
		change_selector(1)

func change_selector(num: int):
	Shop_scene.get_node("Chests_Scene").visible = false
	Shop_scene.get_node("Cosmetics_Scene").visible = false
	Shop_scene.get_node("Monthly_Scene").visible = false
	Shop_scene.get_node("Premium_Scene").visible = false
	Shop_scene.get_node("Buy_Coins_Scene").visible = false
	Shop_scene.get_node("Redeem_Code_Scene").visible = false
	if num == 1:
		load_Chest()
		Shop_scene.get_node("Chests_Scene").visible = true
	elif num == 2:
		Shop_scene.get_node("Cosmetics_Scene").visible = true
	elif num == 3:
		Shop_scene.get_node("Monthly_Scene").visible = true
	elif num == 4:
		Shop_scene.get_node("Premium_Scene").visible = true
	elif num == 5:
		Shop_scene.get_node("Redeem_Code_Scene").visible = true
	elif num == 6:
		Shop_scene.get_node("Buy_Coins_Scene").visible = true

func change_selector_setting(num: int):
	Settings_Scene.get_node("Sound_Scene").visible = (num == 1)
	Settings_Scene.get_node("Gameplay_Scene").visible = (num == 2)

func Sound_pressed():
	change_selector_setting(1)

func Gameplay_pressed():
	change_selector_setting(2)

func Chests_pressed():
	change_selector(1)

func Cosmetics_pressed():
	change_selector(2)

func Monthly_pressed():
	change_selector(3)

func Premium_pressed():
	change_selector(4)

func Reedem_code_pressed():
	change_selector(5)

func switch_coin_pressed():
	change_selector(6)

func switch_plurana_pressed():
	change_selector(4)

func reedem_code():
	var code: String = Shop_scene.get_node("Redeem_Code_Scene/Code").text
	var cCount: int = 0
	var cValid: bool = true
	var compartments: Array = code.split("-")
	var errorMessage: Label = Shop_scene.get_node("Redeem_Code_Scene/ErrorMessage")
	
	##TODO: Testen ob Code gültig ist, wenn nicht errorMessage.text = "The code you entered does not exist"
	
	for c in compartments:
		cCount += 1
		if len(c) != 4:
			cValid = false
	
	if cCount == 4 && cValid:
		errorMessage.text = ""
		var type: String
		var path: String
		var str_arr: PackedStringArray
		view_reedem_code()
		Shop_scene.get_node("Redeem_Code_Scene/ShowRewards/Claim").visible = true
		for i in codes[code]["CosmeticType"].size():
			type = codes[code]["CosmeticType"][str(i)]
			path = codes[code]["Path"][str(i)]
			if type == "Money":
				str_arr = path.split("#")
				add_money(int(str_arr[1]), str_arr[0])
			elif type == "Chest":
				str_arr = path.split("#")
				var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
				var data: Dictionary = JSON.parse_string(file.get_as_text())
				var count: int = int(data["Chests"][str_arr[0]])
				count += int(str_arr[1])
				data["Chests"][str_arr[0]] = count
				file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
				file.store_string(JSON.stringify(data))
				file.close()
			else:
				add_Cosmetic(load("res://Scriptable Object Recources/Cosmetics/" + type + "/" + path))
	else:
		errorMessage.text = "The code you entered is in the wrong format"

func view_reedem_code():
	clear_view_reedem_code()
	toggle_view_rewards_window()
	Shop_scene.get_node("Redeem_Code_Scene/ShowRewards/Claim").visible = false
	var code: String = Shop_scene.get_node("Redeem_Code_Scene/Code").text
	var prefab: Control = Shop_scene.get_node("Redeem_Code_Scene/ShowRewards/ScrollContainer/GridContainer/Prefab")
	var item: Control
	var cos: Cosmetic
	var type: String
	var path: String
	var str_arr: PackedStringArray
	for i in codes[code]["CosmeticType"].size():
		type = codes[code]["CosmeticType"][str(i)]
		path = codes[code]["Path"][str(i)]
		item = prefab.duplicate()
		Shop_scene.get_node("Redeem_Code_Scene/ShowRewards/ScrollContainer/GridContainer").add_child(item)
		if type == "Money":
			str_arr = path.split("#")
			if str_arr[0] == "Tok":
				item.get_node("Image").texture = load("res://Textures/Menü/Tokens.png")
			elif str_arr[0] == "Coi":
				item.get_node("Image").texture = load("res://Textures/Menü/Coins.png")
			elif str_arr[0] == "Plu":
				item.get_node("Image").texture = load("res://Textures/UI/Items/Ores/Plurana.png")
			item.get_node("Type").texture = load("res://Textures/Menü/Coins_Icon.png")
			item.get_node("Name").text = str_arr[1]
		elif type == "Chest":
			str_arr = path.split("#")
			if str_arr[0] == "Fre":
				item.get_node("Image").texture = load("res://Textures/Menü/Chests/FreeChest.png")
			elif str_arr[0] == "1":
				item.get_node("Image").texture = load("res://Textures/Menü/Chests/1Chest.png")
			elif str_arr[0] == "2":
				item.get_node("Image").texture = load("res://Textures/Menü/Chests/2Chest.png")
			elif str_arr[0] == "3":
				item.get_node("Image").texture = load("res://Textures/Menü/Chests/3Chest.png")
			elif str_arr[0] == "Pre":
				item.get_node("Image").texture = load("res://Textures/Menü/Chests/PremiumChest.png")
			item.get_node("Type").texture = load("res://Textures/Menü/Chest_Icon.png")
			item.get_node("Name").text = str_arr[1]
		else:
			cos = load("res://Scriptable Object Recources/Cosmetics/" + type + "/" + path)
			item.get_node("Image").texture = cos.image
			item.get_node("Name").text = cos.name
			item.get_node("Type").texture = load("res://Textures/Menü/" + cos.type +"_Icon.png")
			if Cosmetic_in_Inv(cos):
				item.get_node("Dublicate").visible = true
		item.visible = true

func clear_view_reedem_code():
	var container: GridContainer = Shop_scene.get_node("Redeem_Code_Scene/ShowRewards/ScrollContainer/GridContainer")
	for child in container.get_children():
		if child.name != "Prefab":
			child.queue_free()

func toggle_view_rewards_window():
	Shop_scene.get_node("Redeem_Code_Scene/ShowRewards").visible = !Shop_scene.get_node("Redeem_Code_Scene/ShowRewards").visible

func load_money():
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	Tokens = int(data["Money"]["Tok"])
	Coins = int(data["Money"]["Coi"])
	Plurana = int(data["Money"]["Plu"])
	get_node("Canvas/Shop_Scene/Tokens/Label").text = format_number(Tokens)
	get_node("Canvas/Shop_Scene/Coins/Label").text = format_number(Coins)
	get_node("Canvas/Shop_Scene/Plurana/Label").text = format_number(Plurana)

func format_number(number: int):
	var parts: Array = str(number).split(".")
	
	# Tausender-Trennzeichen hinzufügen
	var integer_part: String = parts[0]
	var formatted_number: String = ""
	
	for i in range(integer_part.length() - 1, -1, -1):
		formatted_number = integer_part[i] + formatted_number
		if i > 0 and (integer_part.length() - i) % 3 == 0:
			formatted_number = " " + formatted_number
	
	# Dezimalteil (falls vorhanden) wieder hinzufügen
	if parts.size() > 1:
		formatted_number += "." + parts[1]
	
	return formatted_number

func World_Manager_Back():
	change_scene(1)

func create_new_world_button():
	change_scene(3)

func clear_saved_worlds():
	var container: GridContainer = World_Manager_scene.get_node("Load_World/ScrollContainer/GridContainer")
	for child in container.get_children():
		if child.name != "Prefab":
			child.queue_free()

func load_saved_worlds():
	clear_saved_worlds()
	var dir: DirAccess = DirAccess.open(world_path)
	var world_name: String
	var container: GridContainer = World_Manager_scene.get_node("Load_World/ScrollContainer/GridContainer")
	var prefab: TextureButton = container.get_node("Prefab")
	var world: TextureButton
	
	for file in dir.get_files():
		world_name = file
		world_name = world_name.split(".save")[0]
		world = prefab.duplicate()
		container.add_child(world)
		world.get_node("World_Name").text = world_name
		world.visible = true

##Called when Shop button is pressed
func _on_shop_button_pressed():
	change_scene(4)

##Called when Settings button is pressed
func _on_settings_button_pressed():
	change_scene(5)

func load_world(world_name: String):
	SceneHandler.create_world = false
	SceneHandler.world_name = world_name
	var file: FileAccess  = FileAccess.open(world_path + world_name + ".save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	get_tree().change_scene_to_file("res://Scenes/Planets/" + data["player_data"]["Pla"] + ".tscn")

func create_world():
	var name: String = World_Manager_scene.get_node("Create_World/InputField").text
	if !FileAccess.file_exists(world_path + name + ".save") && name != "":
		SceneHandler.create_world = true
		SceneHandler.world_name = name
		get_tree().change_scene_to_file("res://Scenes/story_sequenz.tscn")
	else:
		pass ##TODO: Worldname already exist

func delete_world(world_name: String):
	if FileAccess.file_exists(world_path + world_name + ".save"):
		DirAccess.remove_absolute(world_path + world_name + ".save")
	load_saved_worlds()

func toggle_open_chest():
	Open_Chest.visible = !Open_Chest.visible

func clear_open_Chest():
	var Grid: HBoxContainer = Open_Chest.get_node("HBoxContainer")
	for i in Grid.get_children():
		if i.name != "Prefab":
			i.queue_free()

func open_Chest(name: String):
	clear_open_Chest()
	toggle_open_chest()
	var chest: openable_chest = load("res://Scriptable Object Recources/Openable Chest/" + name + "Chest.tres")
	var items: int = randi_range(chest.min_items, chest.max_items)
	del_Chest(name)
	for i in items:
		open_item(pick_item(chest))

func open_item(item: Cosmetic):
	var Grid: HBoxContainer = Open_Chest.get_node("HBoxContainer")
	var prefab: TextureRect = Grid.get_node("Prefab")
	var item_card: TextureRect
	item_card = prefab.duplicate()
	Grid.add_child(item_card)
	item_card.get_node("Image").texture = item.image
	item_card.get_node("Name").text = item.name
	item_card.get_node("Type").texture = load("res://Textures/Menü/" + item.type +"_Icon.png")
	if item.Probability <= 10:
		item_card.get_node("Probability").self_modulate = Color("c5c500")
	elif item.Probability <= 40:
		item_card.get_node("Probability").self_modulate = Color("007195")
	else:
		item_card.get_node("Probability").self_modulate = Color("007c3b")
	item_card.visible = true
	
	if item.type == "Coins":
		if item.name == "Bit Money":
			add_money(randi_range(10, 40), "Coi")
		elif item.name == "Little Money":
			add_money(randi_range(80, 120), "Coi")
		elif item.name == "Much Money":
			add_money(randi_range(160, 250), "Coi")
	else:
		if !add_Cosmetic(item):
			var coins: int = 550/item.Probability
			item_card.get_node("Dublicate").visible = true
			item_card.get_node("Dublicate/Money").text = "+" + str(coins)
			add_money(coins, "Coi")

func add_Cosmetic(cos: Cosmetic) -> bool:
	if !Cosmetic_in_Inv(cos):
		var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		var items: Dictionary = data["Cosmetics"][cos.type]
		var resource_path: String
		resource_path = cos.resource_path
		resource_path = resource_path.split("res://Scriptable Object Recources/Cosmetics/" + cos.type + "/")[1]
		var size: int = items.size()
		data["Cosmetics"][cos.type][str(size)] = resource_path
		file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
		file.close()
		return true
	return false

func Cosmetic_in_Inv(cos: Cosmetic) -> bool:
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var items: Dictionary = data["Cosmetics"][cos.type]
	var resource_path: String
	resource_path = cos.resource_path
	resource_path = resource_path.split("res://Scriptable Object Recources/Cosmetics/" + cos.type + "/")[1]
	#Cycle trough all Items with that Type and test if already in Inventory, if not, add it
	for i in items.size():
		if resource_path == items[str(i)]:
			return true #Already in Inventory
	return false

func add_money(number: int, type: String):
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var Coins: int = int(data["Money"][type])
	Coins += number
	data["Money"][type] = str(Coins)
	file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	load_money()

func pick_item(chest: openable_chest) -> Cosmetic:
	
	var totalProbability: int
	for i in chest.item:
		totalProbability += i.Probability
	var randomValue = randi() % totalProbability
	var cumulativeProbability = 0
	for i in chest.item:
		cumulativeProbability += i.Probability
		if randomValue < cumulativeProbability:
			return i
	return null

func open_Free():
	open_Chest("Free")

func open_one():
	open_Chest("1")

func open_two():
	open_Chest("2")

func open_three():
	open_Chest("3")

func open_Premium():
	open_Chest("Premium")

func toggle_chest_info():
	Chest_Info.visible = !Chest_Info.visible

func clear_chest_info():
	var Grid: GridContainer = Chest_Info.get_node("ScrollContainer/GridContainer")
	for i in Grid.get_children():
		if i.name != "Prefab":
			i.queue_free()

func chest_info(name: String):
	clear_chest_info()
	var chest: openable_chest = load("res://Scriptable Object Recources/Openable Chest/" + name + "Chest.tres")
	var prefab: Control = Chest_Info.get_node("ScrollContainer/GridContainer/Prefab")
	var item: Control
	var item_Array: Array[Cosmetic] = chest.item
	toggle_chest_info()
	item_Array.sort_custom(sort_by_Probability)
	for i in item_Array:
		item = prefab.duplicate()
		Chest_Info.get_node("ScrollContainer/GridContainer").add_child(item)
		item.get_node("Image").texture = i.image
		item.get_node("Name").text = i.name
		item.get_node("Probability").text = str(i.Probability) + "%"
		item.get_node("Type").texture = load("res://Textures/Menü/" + i.type +"_Icon.png")
		if i.Probability <= 10:
			item.get_node("Background").self_modulate = Color("c5c500")
		elif i.Probability <= 40:
			item.get_node("Background").self_modulate = Color("007195")
		else:
			item.get_node("Background").self_modulate = Color("007c3b")
		item.visible = true

func sort_by_Probability(a: Cosmetic, b: Cosmetic) -> bool:
	if a.Probability > b.Probability:
		return true
	return false

func info_Free():
	chest_info("Free")

func info_one():
	chest_info("1")

func info_two():
	chest_info("2")

func info_three():
	chest_info("3")

func info_Premium():
	chest_info("Premium")

func del_Chest(name: String):
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	var Free: int
	var Premium: int
	var one: int
	var two: int
	var three: int
	
	if name == "Free":
		Free = int(data["Chests"]["Fre"])
		Free -= 1
		data["Chests"]["Fre"] = str(Free)
	elif name == "1":
		one = int(data["Chests"]["1"])
		one -= 1
		data["Chests"]["1"] = str(one)
	elif name == "2":
		two = int(data["Chests"]["2"])
		two -= 1
		data["Chests"]["2"] = str(two)
	elif name == "3":
		three = int(data["Chests"]["3"])
		three -= 1
		data["Chests"]["3"] = str(three)
	elif name == "Premium":
		Premium = int(data["Chests"]["Pre"])
		Premium -= 1
		data["Chests"]["Pre"] = str(Premium)
	
	file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	load_Chest()

func add_Chest(name: String):
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var Tokens: int = int(data["Money"]["Tok"])
	var Coins: int = int(data["Money"]["Coi"])
	var Plurana: int = int(data["Money"]["Plu"])
	file.close()
	var Free: int
	var Premium: int
	var one: int
	var two: int
	var three: int
	
	if name == "Free":
		Free = int(data["Chests"]["Fre"])
		Free += 1
		data["Chests"]["Fre"] = str(Free)
	elif name == "1" && Tokens >= 20000:
		Tokens -= 20000
		data["Money"]["Tok"] = Tokens
		one = int(data["Chests"]["1"])
		one += 1
		data["Chests"]["1"] = str(one)
	elif name == "2" && Coins >= 800:
		Coins -= 800
		data["Money"]["Coi"] = Coins
		two = int(data["Chests"]["2"])
		two += 1
		data["Chests"]["2"] = str(two)
	elif name == "3" && Coins >= 1200:
		Coins -= 1200
		data["Money"]["Coi"] = Coins
		three = int(data["Chests"]["3"])
		three += 1
		data["Chests"]["3"] = str(three)
	elif name == "Premium" && Plurana >= 1225:
		Plurana -= 1225
		data["Money"]["Plu"] = Plurana
		Premium = int(data["Chests"]["Pre"])
		Premium += 1
		data["Chests"]["Pre"] = str(Premium)
	
	file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	load_money()
	load_Chest()

func load_Chest():
	clear_Chest()
	var chestPrefab: TextureRect = Shop_scene.get_node("Chests_Scene/ChestInventory/Prefab")
	var chest: TextureRect
	var Inventory: HBoxContainer = Shop_scene.get_node("Chests_Scene/ChestInventory")
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	var Free: int = int(data["Chests"]["Fre"])
	var one: int = int(data["Chests"]["1"])
	var two: int = int(data["Chests"]["2"])
	var three: int = int(data["Chests"]["3"])
	var Premium: int = int(data["Chests"]["Pre"])
	if Free >= 1:
		chest = chestPrefab.duplicate()
		Inventory.add_child(chest)
		chest.texture = load("res://Textures/Menü/Chests/FreeChest.png")
		chest.get_node("Count").text = str(Free)
		chest.get_node("Open").connect("pressed", open_Free)
		chest.name = "FreeChest"
		chest.visible = true
	if one >= 1:
		chest = chestPrefab.duplicate()
		Inventory.add_child(chest)
		chest.texture = load("res://Textures/Menü/Chests/1Chest.png")
		chest.get_node("Count").text = str(one)
		chest.get_node("Open").connect("pressed", open_one)
		chest.name = "1Chest"
		chest.visible = true
	if two >= 1:
		chest = chestPrefab.duplicate()
		Inventory.add_child(chest)
		chest.texture = load("res://Textures/Menü/Chests/2Chest.png")
		chest.get_node("Count").text = str(two)
		chest.get_node("Open").connect("pressed", open_two)
		chest.name = "2Chest"
		chest.visible = true
	if three >= 1:
		chest = chestPrefab.duplicate()
		Inventory.add_child(chest)
		chest.texture = load("res://Textures/Menü/Chests/3Chest.png")
		chest.get_node("Count").text = str(three)
		chest.get_node("Open").connect("pressed", open_three)
		chest.name = "3Chest"
		chest.visible = true
	if Premium >= 1:
		chest = chestPrefab.duplicate()
		Inventory.add_child(chest)
		chest.texture = load("res://Textures/Menü/Chests/PremiumChest.png")
		chest.get_node("Count").text = str(Premium)
		chest.get_node("Open").connect("pressed", open_Premium)
		chest.name = "PremiumChest"
		chest.visible = true

func clear_Chest():
	var Inventory: HBoxContainer = Shop_scene.get_node("Chests_Scene/ChestInventory")
	if Inventory.get_child_count() >= 1: #>= beacause prefab is ignored
		for i in Inventory.get_children():
			if "Chest" in i.name:
				i.queue_free()

func buy_Free_Chest():
	add_Chest("Free")

func buy_1_Chest():
	add_Chest("1")

func buy_2_Chest():
	add_Chest("2")

func buy_3_Chest():
	add_Chest("3")

func buy_Premium_Chest():
	add_Chest("Premium")

func clear_inv():
	var Grid: GridContainer = Shop_scene.get_node("Cosmetics_Scene/Inv_Scene/ScrollContainer/GridContainer")
	for item in Grid.get_children():
		if item.name != "Prefab":
			item.queue_free()

func load_inv(name: String):
	clear_inv()
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var inv: Dictionary = JSON.parse_string(file.get_as_text())["Cosmetics"][name]
	var Grid: GridContainer = Shop_scene.get_node("Cosmetics_Scene/Inv_Scene/ScrollContainer/GridContainer")
	var Prefab: Control = Grid.get_node("Prefab")
	var item: Cosmetic
	var item_card: Control
	if inv.size() <= 0:
		Shop_scene.get_node("Cosmetics_Scene/Inv_Scene/EmtpyText").visible = true
	else:
		Shop_scene.get_node("Cosmetics_Scene/Inv_Scene/EmtpyText").visible = false
	for i in inv.size():
		item = load("res://Scriptable Object Recources/Cosmetics/" + name + "/" + inv[str(i)])
		item_card = Prefab.duplicate()
		item_card.get_node("Image").texture = item.image
		item_card.get_node("Name").text = item.name
		Grid.add_child(item_card)
		item_card.visible = true

func open_inv(name: String):
	Shop_scene.get_node("Cosmetics_Scene/Inv_Scene").visible = !Shop_scene.get_node("Cosmetics_Scene/Inv_Scene").visible
	if Shop_scene.get_node("Cosmetics_Scene/Inv_Scene").visible:
		load_inv(name)

func toggle_animal_Inv():
	open_inv("Animal")

func toggle_backback_Inv():
	open_inv("Backback")

func toggle_footsteps_Inv():
	open_inv("Footsteps")

func toggle_hats_Inv():
	open_inv("Hat")

func toggle_inactivity_Inv():
	open_inv("Inactivity")

func toggle_item_Inv():
	open_inv("Item")

func toggle_pet_Inv():
	open_inv("Pet")

func toggle_skin_Inv():
	open_inv("Skin")

func toggle_Title_Inv():
	open_inv("Title")

func buy_Coins(pack: int, cost: int, reward: int):
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var Coins: int = int(data["Money"]["Coi"])
	var Plurana: int = int(data["Money"]["Plu"])
	file.close()
	if Plurana >= cost:
		data["Money"]["Plu"] = Plurana - cost
		data["Money"]["Coi"] = Coins + reward
	file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	load_money()

func buy_Coins_1():
	buy_Coins(1, 650, 1950)

func buy_Coins_2():
	buy_Coins(2, 2430, 10450)

func buy_Coins_3():
	buy_Coins(3, 4120, 16570)

func buy_Premium_1():
	buy_Premium(1)

func buy_Premium_2():
	buy_Premium(2)

func buy_Premium_3():
	buy_Premium(3)

func buy_Premium(pack: int):
	##TODO: Implement Google Payment
	var file: FileAccess  = FileAccess.open(data_path + "inventory.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var Plurana: int = int(data["Money"]["Plu"])
	file.close()
	if pack == 1: ##Cost: 1,99€
		data["Money"]["Plu"] = Plurana + 820
	elif pack == 2: ##Cost: 4,99€
		data["Money"]["Plu"] = Plurana + 3430
	elif pack == 3: ##Cost: 9,99€
		data["Money"]["Plu"] = Plurana + 7090
	file = FileAccess.open(data_path + "inventory.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	load_money()

func Check_ItemAddon():
	var checked: TextureRect = Settings_Scene.get_node("Gameplay_Scene/ScrollContainer/VBoxContainer/ItemAddon/CheckSlider/Checked")
	checked.visible = !checked.visible
	var file: FileAccess  = FileAccess.open(data_path + "settings.save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	if checked.visible:
		data["Gameplay"]["ItemAddon"] = "1"
	else:
		data["Gameplay"]["ItemAddon"] = "0"
	file = FileAccess.open(data_path + "settings.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
