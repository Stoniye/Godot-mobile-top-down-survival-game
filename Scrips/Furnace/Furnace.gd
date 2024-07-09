extends Sprite2D

var Items: Array[InventoryItem]

#region Const
const input: int = 0
const fuel: int = 1
const output: int = 2
#endregion

#region Variables for Process
var progress: int = 0
var energie: int = 0
var energie_needed: int = 0
var item_in: Item
#endregion

##Smelting Process
func smelt():
	##TODO: If any Item is removed while smelting process => error (maby save Input and Fuel for ever Tic in a variable and don't read it out of slot)
	if progress <= 0 && Items[input].count >= 1: #Take new Input
		if Items[output].item != null && Items[input].item.smelt_item != Items[output].item:
			return #Canlce because in Output is something else
		item_in = Items[input].item
		energie_needed = Items[input].item.smelt_energie
		Items[input].count -= 1
	if energie <= 0 && Items[fuel].count >= 1: #Take new fuel
		Items[fuel].count -= 1
		energie = Items[fuel].item.fuel_energie
	
	energie -= 1
	progress += 1
	if progress >= energie_needed:
		progress = 0
		energie = 0
		Items[output].item = item_in.smelt_item
		Items[output].count += 1
	update_UI()
	if Items[input].count <= 0 && Items[fuel].count <= 0 && energie <= 0:
		set_smelting(false)

##Connect/Disconnects Smelting to Tic signal
func set_smelting(state: bool):
	if state:
		get_node("../Time_Manager").connect("tic", smelt)
	else:
		get_node("../Time_Manager").disconnect("tic", smelt)

##Loads Items from furnace in Furnace Window
func update_UI():
	get_node("../Canvas/UI").load_furnace()

func test_for_smelting():
	if (Items[input].count >= 1 && Items[fuel].count >= 1) || energie >= 1:
		set_smelting(true)

func init_array():
	for i in 3:
		Items.append(InventoryItem.new())
