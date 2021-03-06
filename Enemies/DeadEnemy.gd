extends StaticBody

var loot: Dictionary = {
	"SKS_ammo" : 10
}

var _looted = false

func interact() -> Dictionary:
	if _looted:
		return {}
	_looted = true
	return loot
