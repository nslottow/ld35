package;

import luxe.Scene;
import luxe.Entity;
import luxe.Vector;
import luxe.Log.*;

import luxe.tilemaps.Tilemap;
import luxe.importers.tiled.TiledMap;

import entities.*;
import components.TileMovement;

class Level {
	public static var tile_width:Float;
	public static var tile_height:Float;
	public static var tile_scale:Float;

	static var scene:Scene;
	static var tiled_map:TiledMap;
	static var tiles:Array<Tile>;
	static var tiles_x:Int;
	static var tiles_y:Int;

	static var movable_entities:Array<TileMovement>;

	public static function destroy() {
		if (scene != null) {
			scene.empty();
		}

		if (tiled_map != null) {
			tiled_map.destroy();
		}
	}

	public static function load_json(json_str:String) {
		if (scene == null) {
			scene = new Scene('level');
		} else {
			scene.empty();
		}

		if (tiled_map != null) {
			// Destroy the old map
			tiled_map.destroy();
		}

		tiled_map = new TiledMap({
			asset_path: 'assets/maps',
			tiled_file_data: json_str,
			format: 'json',
		});

		// Scale the tilemap so the whole thing fits horizontally within the window
		tile_scale = Main.w_points / (tiled_map.tile_width * tiled_map.width);
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

		// TODO: Instantiate objects into the level's scene
		movable_entities = [];

		// For now we're just creating a random smattering of units, some inactive
		var random = Luxe.utils.random;
		var units:Array<PlayerUnit> = [];

		var available_tiles = tiles.copy();

		for (i in 0...9) {
			var unit = new PlayerUnit({
				scene: scene,
				size: new Vector(tile_width, tile_height),
				depth: 100
			});

			var dest_tile = available_tiles[random.int(available_tiles.length)];
			available_tiles.remove(dest_tile);
			unit.tile_movement.move_to(dest_tile.x, dest_tile.y, false);

			units.push(unit);
			movable_entities.push(unit.tile_movement);
		}

		// Activate a random number of units
		var active_count = Math.floor(Math.max(1, random.int(units.length)));
		for (i in 0...active_count) {
			units[i].controller = PlayerController.instance;
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
	
	/** Entities on this tile */
	public var entities:Array<Entity> = [];

	public var neighbors:Array<Tile>;

	public function new(_x:Int, _y:Int) {
		x = _x;
		y = _y;
	}
}
