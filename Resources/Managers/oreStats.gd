extends Resource

class_name OreStats

@export var icon :Texture2D

@export var name :String

static func isOre(item) -> bool:
	if item == "Coal" or item == "Fluorite" or item == "Quartz" or item == "Ruby" or item == "Titanium" or item == "Topaz" or item == "Tungsten":
		return true
	return false
