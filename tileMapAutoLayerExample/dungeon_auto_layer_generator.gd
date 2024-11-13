extends Node
## This file gets added in project settings -> globals, under the DungeonAutoLayerGenerator name

enum Tiles { EMPTY, SOLID }

class Room:
    var position:Vector2i
    var dimensions:Vector2i
    var centerpoint:Vector2i


var dugRooms = []
var rng = RandomNumberGenerator.new()
var cells_to_dig = {} # dict so we treat it as a set

var mapWidth
var mapHeight

func _ready():
    rng.randomize()


func generate(map:TileMapLayer, w:int, h:int, minRoomSize, maxRoomSize):
    map.clear()
    var potentialRooms:int = (w / maxRoomSize) * (h / maxRoomSize)
    var rooms:Dictionary
    var room:Room
    var position:Vector2i

    var start:Vector2i
    var end:Vector2i

    var modifier:int

    var key:String
    
    mapWidth = w
    mapHeight = h
    cells_to_dig.clear()
    """
    # Fill map with solid tiles, adding a "border" of solid tiles around the map
    # out of bounds.
    for r in range(-1, h + 1):
        for c in range (-1, w + 1):
            map.set_cell(Vector2i(c, r), 0, Vector2i(Tiles.SOLID, 0))
    """
    # Generate potential rooms.
    for r in potentialRooms:
        position = Vector2i(rng.randi_range(1, w - maxRoomSize), rng.randi_range(1, h - maxRoomSize))

        key = str(position.x) + " " + str(position.y)

        if (!rooms.has(key)):
            room = Room.new()

            room.position    = position
            room.dimensions  = Vector2i(rng.randi_range(minRoomSize, maxRoomSize), rng.randi_range(minRoomSize, maxRoomSize))
            room.centerpoint = room.position + Vector2i(roundi(room.dimensions.x / 2), roundi(room.dimensions.y / 2))

            rooms[key] = room

            digRoom(room)
    
    # Connect dug rooms.
    dugRooms = rooms.values().duplicate()
    
    for r in dugRooms.size() - 1:
        start = Vector2i(dugRooms[r].centerpoint.x, dugRooms[r].centerpoint.y)
        end = Vector2i(dugRooms[r + 1].centerpoint.x, dugRooms[r + 1].centerpoint.y)

        if (start.y < end.y):
            modifier = 1
        else:
            modifier = -1

        # making the vertical paths to the room
        var offsetx = start.x
        if start.x <= 1:
            offsetx += 1
        else:
            offsetx -= 1
        for row in range(start.y, end.y, modifier):
            if shouldDigCell(Vector2i(start.x, row)):
                addToCellsToDig(Vector2i(start.x, row))
                addToCellsToDig(Vector2i(offsetx, row))


        if (start.x < end.x):
            modifier = 1
        else:
            modifier = -1

        # making the horizontal paths to the room
        var offsety = end.y
        if end.y <= 1:
            offsety += 1
        else:
            offsety -= 1

        for col in range(start.x, end.x, modifier):           
            if shouldDigCell(Vector2i(col, end.y)):
                addToCellsToDig(Vector2i(col, end.y))
                addToCellsToDig(Vector2i(col, offsety))
                print("digging pair " + str(Vector2i(col, offsety)) + ", " + str(Vector2i(col, end.y)))

    #removeLoneCells()
    var all_cells = getCellsToDig()
    map.set_cells_terrain_connect(all_cells, 0, 0)

func digRoom(room):
    for x in range(room.position.x, room.position.x + room.dimensions.x - 1):
        for y in range(room.position.y, room.position.y + room.dimensions.y - 1):
            addToCellsToDig(Vector2i(x, y))


func shouldDigCell(pos):
    if ((pos.x < mapWidth) && (pos.y < mapHeight)):
        return true


func addToCellsToDig(pos: Vector2i):
    if cells_to_dig.has(pos):
        return
    cells_to_dig[pos] = null

func getCellsToDig()->Array:
    return cells_to_dig.keys()


func cellBareSides(a:Vector2i, b:Vector2i):
    if not cells_to_dig.has(a) and not cells_to_dig.has(b):
        return true
    return false


func removeLoneCells():
    var keys = getCellsToDig()
    var keys_to_remove = []
    for i in keys:        
        var left_right = cellBareSides(Vector2i(i.x-1, i.y), Vector2i(i.x+1, i.y))
        var top_down = cellBareSides(Vector2i(i.x, i.y-1), Vector2i(i.x+1, i.y+1))
        if left_right or top_down:
            keys_to_remove.append(i)
    for i in keys_to_remove:
        cells_to_dig.erase(i)

        
