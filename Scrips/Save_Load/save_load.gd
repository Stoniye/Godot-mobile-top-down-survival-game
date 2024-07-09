extends Node2D

@onready var Player: CharacterBody2D = $"../Player"
@onready var UI: CanvasGroup = $"../Canvas/UI"
@onready var Root: Node2D = $".."

##Variables for Process
const path = "user://gamedata/Worlds/"
@onready var Ground_Map: TileMap = $"../Ground"
@onready var Water_Map: TileMap = $"../Water"

func _ready():
	
	var array: Array[InventoryItem]
	for i in 10:
		array.append(InventoryItem.new())
	load_travel_chest(array)
	
	#Create new World
	if SceneHandler.create_world:
		save_world(SceneHandler.world_name)
	
	else: #Load Saved World
		if get_tree().current_scene.name == "Azuria":
			load_world(SceneHandler.world_name)
		elif get_tree().current_scene.name == "Huvle":
			var data: Dictionary = load_data(SceneHandler.world_name)
			if SceneHandler.traveld:
				load_player_data(data)
				load_inv(data)
				load_trave_chest_from_JSON(data)
				generate_planet()
			else:
				load_world(SceneHandler.world_name)
			SceneHandler.traveld = false
	SceneHandler.create_world = false

func generate_planet():
	
	var Obj: Sprite2D
	var spawn_rate: int = randi_range(15, 50)
	
	for i in spawn_rate:
		Obj = UI.building_node.instantiate()
		get_node("..").add_child.call_deferred(Obj)
		Obj.position = Vector2(UI.clamp_to_int(randi_range(-1024, 1024), 32), UI.clamp_to_int(randi_range(-672, 672), 16))
		Obj.texture = load("res://Textures/Planets/Huvle/Iron_Ore.png")
		Obj.get_node("Item").inv_item = InventoryItem.new()
		Obj.get_node("Item").inv_item.item = load("res://Scriptable Object Recources/Items/Ores/Raw_Ores/Raw_Iron.tres")
		Obj.get_node("Item").inv_item.count = randi_range(1, 2)
		Obj.get_node("Item").inv_item.durability = 25
		Obj.add_to_group("Saveable")
	
	spawn_rate = randi_range(15, 50)
	
	for i in spawn_rate:
		Obj = UI.building_node.instantiate()
		get_node("..").add_child.call_deferred(Obj)
		Obj.position = Vector2(UI.clamp_to_int(randi_range(-1024, 1024), 32), UI.clamp_to_int(randi_range(-672, 672), 16))
		Obj.texture = load("res://Textures/Planets/Huvle/Coal_Ore.png")
		Obj.get_node("Item").inv_item = InventoryItem.new()
		Obj.get_node("Item").inv_item.item = load("res://Scriptable Object Recources/Items/Ores/Ores/Coal.tres")
		Obj.get_node("Item").inv_item.count = randi_range(1, 2)
		Obj.get_node("Item").inv_item.durability = 15
		Obj.add_to_group("Saveable")
	
	spawn_rate = randi_range(40, 60)
	
	for i in spawn_rate:
		Obj = UI.building_node.instantiate()
		get_node("..").add_child.call_deferred(Obj)
		Obj.position = Vector2(UI.clamp_to_int(randi_range(-1024, 1024), 32), UI.clamp_to_int(randi_range(-672, 672), 16))
		Obj.texture = load("res://Textures/Planets/Huvle/Copper_Ore.png")
		Obj.get_node("Item").inv_item = InventoryItem.new()
		Obj.get_node("Item").inv_item.item = load("res://Scriptable Object Recources/Items/Ores/Raw_Ores/Raw_Copper.tres")
		Obj.get_node("Item").inv_item.count = randi_range(1, 2)
		Obj.get_node("Item").inv_item.durability = 30
		Obj.add_to_group("Saveable")

##Saves world with name <world_name> in standard folder
func save_world(save_world_name: String):
	
	SceneHandler.world_name = save_world_name
	
	#Save Player Data
	var saved_data: Dictionary = {}
	var map_data: Dictionary = {}
	var build_data: Dictionary = {}
	var planet_map_data: Dictionary = {}
	var planet_build_data: Dictionary = {}
	
	if get_tree().current_scene.name == "Azuria":
		map_data = {
			"Gro": tilemap_to_JSON(Ground_Map),
			"Wat": tilemap_to_JSON(Water_Map)
		}
		build_data = {
			"Build": Builds_to_JSON()
		}
		planet_build_data = {
			"Build": "Null"
		}
		planet_map_data = {
			"Gro": "Null"
		}
	else: ##TODO: Azuria map data nicht zwischen speichern, sonder einfach planet_build_data und planet_map_data schreiben
		saved_data = load_data(SceneHandler.world_name)
		map_data = {
			"Gro": saved_data["Maps"]["1"]["Gro"],
			"Wat": saved_data["Maps"]["1"]["Wat"]
		}
		build_data = {
			"Build": saved_data["Builds"]["1"]["Build"]
		}
		planet_build_data = {
			"Build": Builds_to_JSON()
		}
		planet_map_data = {
			"Gro": tilemap_to_JSON(Ground_Map),
			"Wat": "Null"
		}
	
	var file: FileAccess = FileAccess.open(path + save_world_name + ".save", FileAccess.WRITE)
	var data: Dictionary = {
		
		#Save Player Data
		"player_data": {
			"Nam": Player.PlayerName,
			"pos":{
				"x": Player.position.x,
				"y": Player.position.y
			},
			"Hea": Player.Health,
			"MHe": Player.MaxHealth,
			"Lev": Player.Level,
			"XP": Player.XP,
			"Pla": get_tree().current_scene.name,
			"tra": Inv_to_JSON(Root.get_node("Rocket_Chest").chest_inv)
		},
		#Save Maps
		"Maps": {
			"1": map_data,
			"2": planet_map_data
		},
		#Save Inv's
		"Inventory": {
			"Inv": Inv_to_JSON(UI.Inventory),
			"Hot": Inv_to_JSON(UI.Hotbar),
			"Equ": Inv_to_JSON(UI.Equipment)
		},
		#Save Builds
		"Builds": {
			"1": build_data,
			"2": planet_build_data
		}
	}
	file.store_string(JSON.stringify(data))
	file.close()

func load_inv(data: Dictionary):
	JSON_to_Inv(UI.Inventory, data["Inventory"]["Inv"])
	JSON_to_Inv(UI.Hotbar, data["Inventory"]["Hot"])
	JSON_to_Inv(UI.Equipment, data["Inventory"]["Equ"])

func load_player_data(data: Dictionary):
	Player.PlayerName = data["player_data"]["Nam"]
	Player.Health = data["player_data"]["Hea"]
	Player.MaxHealth = data["player_data"]["MHe"]
	Player.Level = data["player_data"]["Lev"]
	Player.XP = data["player_data"]["XP"]
	UI.manage_Equipment()

func load_trave_chest_from_JSON(data: Dictionary):
	var inv_data: Dictionary = data["player_data"]["tra"]
	var load_inv: Array[InventoryItem]
	for i in 10:
		load_inv.append(InventoryItem.new())
		if inv_data[str(i)] != "null":
			var string: PackedStringArray = inv_data[str(i)].split("#")
			load_inv[i].item = load("res://Scriptable Object Recources/Items/" + string[0])
			load_inv[i].count = int(string[1])
			load_inv[i].durability = int(string[2])
		else:
			load_inv[i] = InventoryItem.new()
			
	load_travel_chest(load_inv)

func load_data(load_world_name: String) -> Dictionary:
	var file: FileAccess  = FileAccess.open(path + load_world_name + ".save", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	return data

##Loads world with name <world_name> out standard folder
func load_world(load_world_name: String):
	if FileAccess.file_exists(path + load_world_name + ".save"):
		
		SceneHandler.world_name = load_world_name
		
		#Load Data
		var data: Dictionary = load_data(load_world_name)
		
		#Load Inv's
		load_inv(data)
		
		#Load Player Data
		load_player_data(data)
		Player.position = Vector2(float(data["player_data"]["pos"]["x"]), float(data["player_data"]["pos"]["y"]))
		
		#Load Maps
		if get_tree().current_scene.name == "Azuria":
			JSON_to_tilemap(Ground_Map, data["Maps"]["1"]["Gro"])
			JSON_to_tilemap(Water_Map, data["Maps"]["1"]["Wat"])
		else:
			JSON_to_tilemap(Ground_Map, data["Maps"]["2"]["Gro"])
		
		#Load Builds
		if get_tree().current_scene.name == "Azuria":
			JSON_to_Builds(data["Builds"]["1"]["Build"])
		else:
			JSON_to_Builds(data["Builds"]["2"]["Build"])
		
		#Load Travel Inv
		load_trave_chest_from_JSON(data)
		
		UI.update_interact_button()
		UI.update_Action_Panel()

func load_travel_chest(inv: Array[InventoryItem]):
	var chest_inv: Array[InventoryItem] = Root.get_node("Rocket_Chest").chest_inv
	chest_inv.clear()
	Root.get_node("Rocket_Chest").init_Array()
	for i in inv.size():
		chest_inv[i] = inv[i]


##Converting Functions##

func tilemap_to_JSON(tilemap: TileMap) -> String:
	
	#Get the number of layers
	var layers = tilemap.get_layers_count()
	var tile_map_layers = []
	
	#Resize the array to the number of layers
	tile_map_layers.resize(layers)

	#Get the tile_data from each layer
	for layer in layers:
		tile_map_layers[layer] = tilemap.get("layer_%s/tile_data" % layer)

	return JSON.stringify(tile_map_layers)

func JSON_to_tilemap(tilemap: TileMap, data: String):
	
	#Parse the JSON
	var layer_data: Array = JSON.parse_string(data)
	
	#For each entry in the array, set the tilemap layer tile_data
	for layer in layer_data.size():
		var tiles = layer_data[layer]
		tilemap.set('layer_%s/tile_data' % layer, tiles)

func Inv_to_JSON(inv: Array[InventoryItem]) -> Dictionary:
	var data: Dictionary = {}
	var resource_path: String
	
	for i in inv.size():
		if inv[i].item != null:
			resource_path = inv[i].item.resource_path
			resource_path = resource_path.split("res://Scriptable Object Recources/Items/")[1]
			data[i] = resource_path + "#" + str(inv[i].count)  + "#" + str(inv[i].durability)
		else:
			data[i] = "null"
	return data

func JSON_to_Inv(inv: Array[InventoryItem], data: Dictionary):
	
	for i in inv.size():
		if data[str(i)] != "null":
			var string: PackedStringArray = data[str(i)].split("#")
			inv[i].item = load("res://Scriptable Object Recources/Items/" + string[0])
			inv[i].count = int(string[1])
			inv[i].durability = int(string[2])
		else:
			inv[i] = InventoryItem.new()
		UI.load_inv()
		UI.update_hotbar()

func Builds_to_JSON() -> Dictionary:
	var data: Dictionary = {}
	var i: int = -1
	var resource_path: String
	var items: Dictionary
	
	for child in Root.get_children():
		if child.is_in_group("Saveable"):
			
			i+=1
			
			resource_path = child.get_node("Item").inv_item.item.resource_path
			resource_path = resource_path.split("res://Scriptable Object Recources/Items/")[1]
			
			items = {
					"0": "Null"
				}
			
			if child.get_node("Area2D") != null:
				if child.get_node("Area2D").is_in_group("Chest"):
					items = Inv_to_JSON(child.chest_inv)
				elif child.get_node("Area2D").is_in_group("Furnace"):
					items = Inv_to_JSON(child.Items)
			
			data[i] = {
				"Ite": resource_path,
				"pos":{
					"x": child.position.x,
					"y": child.position.y
				},
				"Its": items
			}
	return data

func JSON_to_Builds(data: Dictionary):
	var block: Sprite2D
	var item: Item
	
	for i in data.size():
		item = load("res://Scriptable Object Recources/Items/" + data[str(i)]["Ite"])
		block = UI.place_item(item, item.durability, Vector2(data[str(i)]["pos"]["x"], data[str(i)]["pos"]["y"]))
		if block.get_node("Area2D") != null:
			if block.get_node("Area2D").is_in_group("Chest"):
				JSON_to_Inv(block.chest_inv, data[str(i)]["Its"])
			elif block.get_node("Area2D").is_in_group("Furnace"):
				JSON_to_Inv(block.Items, data[str(i)]["Its"])
