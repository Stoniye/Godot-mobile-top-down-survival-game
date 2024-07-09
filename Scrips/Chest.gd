extends Node

var chest_inv: Array[InventoryItem]

func init_Array():
	for i in 35:
		chest_inv.append(InventoryItem.new())
