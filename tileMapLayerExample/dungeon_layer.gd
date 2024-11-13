extends TileMapLayer

@export var mapWidth = 10
@export var mapHeight = 10

@export var minRoomSize = 5
@export var maxRoomSize = 5

func _ready():
    DungeonLayerGenerator.generate(self, mapWidth, mapHeight, minRoomSize, maxRoomSize)


func _on_button_pressed():
    DungeonLayerGenerator.generate(self, mapWidth, mapHeight, minRoomSize, maxRoomSize)
