package;

import luxe.Scene;
import luxe.Entity;
import luxe.Vector;
import luxe.Log.*;

import luxe.tilemaps.Tilemap;
import luxe.importers.tiled.TiledMap;

import entities.PlayerUnit;
import entities.PlayerController;
import entities.Gunman;
import entities.PlayerController;
import components.TileMovement;

class Level {
	public static var tile_width:Float;
	public static var tile_height:Float;
	public static var tile_scale:Float;

	static var json_str:String;
	static var scene:Scene;
	static var tiled_map:TiledMap;
	static var tiles:Array<Tile>;
	static var tiles_x:Int;
	static var tiles_y:Int;
	static var elevator_tiles:Array<Tile>;
	static var events:luxe.Events;
	static var player:PlayerController;

	public static function destroy() {
		if (scene != null) {
			scene.empty();
		}

		if (tiled_map != null) {
			tiled_map.destroy();
		}

		json_str = null;
	}

	public static function reload() {
		if (json_str != null) {
			trace('reloading level');
			load_json(json_str);
		}
	}

	public static inline function on<T>(event_name:String, handler:T->Void):String {
		return events.listen(event_name, handler);
	}

	public static inline function off(event_connection:String):Bool {
		return events.unlisten(event_connection);
	}

	public static function load_json(_json_str:String) {
		assertnull(_json_str);
		json_str = _json_str;

		events = new luxe.Events();

		if (scene == null) {
			scene = new Scene('level');
		} else {
			scene.empty();
		}

		if (tiled_map != null) {
			// Destroy the old map
			tiled_map.destroy();
		}

		player = new PlayerController({
			scene: scene
		});

		tiled_map = new TiledMap({
			asset_path: 'assets/maps',
			tiled_file_data: json_str,
			format: 'json',
		});

		// Scale the tilemap so the whole thing fits horizontally within the window
		tile_scale = Main.w_points / (tiled_map.tile_width * tiled_map.width);
		if (tile_scale * (tiled_map.height + 1) * tiled_map.tile_height >= Main.h_points) {
			tile_scale = Main.h_points / (tiled_map.tile_height * (tiled_map.height + 1));
		}

		tiled_map.display({
			scale: tile_scale
		});

		tile_width = tiled_map.tile_width * tile_scale;
		tile_height = tiled_map.tile_height * tile_scale;

		// Create game tiles for each tile coordinate in the map
		var data = tiled_map.tiledmap_data;
		assert(data.orientation == TilemapOrientation.ortho);

		tiles_x = data.width;
		tiles_y = data.height;
		tiles = [for (i in 0...tiles_x * tiles_y) null];

		for (y in 0...tiles_y) {
			for (x in 0...tiles_x) {
				tiles[y * tiles_x + x] = new Tile(x, y);
			}
		}

		// Setup tile neighbors
		for (y in 0...tiles_y) {
			for (x in 0...tiles_x) {
				var tile = get_tile(x, y);
				tile.neighbors = [
					get_tile(x + 1, y), // right
					get_tile(x, y - 1), // above
					get_tile(x - 1, y), // left
					get_tile(x, y + 1), // below
				];
			}
		}

		// Mark solid static tiles as solid
		var static_layer = tiled_map.layers_ordered[0];
		var static_tileset = data.tilesets[0];
		elevator_tiles = [];

		if (static_layer != null && static_tileset != null) {
			for (tile in tiles) {
				var tile_id = static_layer.tiles[tile.y][tile.x].id - 1;
				var tile_props = static_tileset.property_tiles.get(tile_id);
				if (tile_props != null) {
					var properties = tile_props.properties;
					if (properties.get('solid') == true) {
						tile.solid = true;
					} else if (properties.get('abyss') == true) {
						tile.abyss = true;
					} else if (properties.get('elevator') == true) {
						tile.elevator = true;
						elevator_tiles.push(tile);
					}
				}
			}
		}

		// Instantiate objects into the level's scene
		for (object_group in data.object_groups) {
			for (object in object_group.objects) {
				var tile_x = Math.floor(object.pos.x / data.tile_width);
				var tile_y = Math.floor(object.pos.y / data.tile_height) - 1;
				//var world_pos = new Vector(tile_x * tile_scale, tile_y * tile_scale);

				var type_name = object.type;
				var cls = Type.resolveClass('entities.$type_name');
				if (cls != null) {
					trace('creating "$type_name" at ($tile_x, $tile_y)');

					var options = {
						scene: scene,
						size: new Vector(tile_width, tile_height),
						centered: false,
						depth: 3
					};

					var obj_props = object.properties;
					for (key in obj_props.keys()) {
						var value = obj_props.get(key);
						var type = Type.typeof(value);
						//trace('  $key($type) : $value');

						Reflect.setField(options, key, value);
					}

					var instance:Entity = cast Type.createInstance(cls, [options]);
					
					var tile_movement:TileMovement = cast instance.get('tile_movement');
					if (tile_movement != null) {
						tile_movement.move_to(tile_x, tile_y, false);
					}
				} else {
					trace('warning: failed to instantiate object of type "$type_name" at ($tile_x, $tile_y)');
				}
			}
		}

		update_tile_state();
		PlayerController.instance.build_groups();
	}

	public static function update_tile_state() {
		// Update tile state
		for (tile in tiles) {
			tile.active_unit = null;
			for (entity in tile.entities) {
				if (Std.is(entity, PlayerUnit)) {
					var unit:PlayerUnit = cast entity;
					if (unit.controller != null) {
						tile.active_unit = unit;
					}
				}
			}
		}
	}

	public static function tick() {
		events.fire('tick');
	}

	public static function check_level_complete() {
		var all_elevators_filled = true;
		var all_units_active = true;
		var active_unit_count = 0;

		for (tile in tiles) {
			if (tile.elevator && tile.active_unit == null) {
				all_elevators_filled = false;
			}
			for (entity in tile.entities) {
				if (Std.is(entity, PlayerUnit)) {
					var unit:PlayerUnit = cast entity;
					if (unit.controller == null) {
						all_units_active = false;
					} else {
						++active_unit_count;
					}
				}
			}
		}

		if (all_elevators_filled && all_units_active && active_unit_count == elevator_tiles.length) {
			trace('Level complete!');
			PlayerController.instance.active = false;
		}
	}

	/** Returns the tile with tile coordinate (x, y) or null */
	public static inline function get_tile(x:Int, y:Int) {
		if (x < 0 || x >= tiles_x || y < 0 || y >= tiles_y) {
			return null;
		}
		return tiles[y * tiles_x + x];
	}

	public static function get_tile_pos(x:Int, y:Int):Vector {
		return tiled_map.tile_pos(x, y, tile_scale);
	}
}

class Tile {
	public var x(default, null):Int;
	public var y(default, null):Int;

	public var solid:Bool = false;
	public var abyss:Bool = false;
	public var elevator:Bool = false;

	public var has_unit:Bool = false;
	
	/** Entities on this tile */
	public var entities:Array<Entity> = [];

	public var active_unit:PlayerUnit;

	public var neighbors:Array<Tile>;

	public function new(_x:Int, _y:Int) {
		x = _x;
		y = _y;
	}
}
