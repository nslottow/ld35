import luxe.Vector;
import luxe.Color;

import luxe.importers.tiled.TiledMap;

class Main extends luxe.Game {
	override function config(config:luxe.AppConfig) {
		config.preload = {
			textures: [
				{ id: 'assets/tilesets/8x8_dungeon.png' },
				{ id: 'assets/tilesets/top_down_dungeon.png' }
			],
			texts: [
				{ id: 'assets/maps/test_00.tmx' },
				{ id: 'assets/maps/test_00.json' }
			]
		};

		return config;
	}

	override function ready() {
		var map_id = 'assets/maps/test_00.tmx';
		trace('Loading tiled map: $map_id');

		var tiled_map = new TiledMap({
			tiled_file_data: Luxe.resources.text(map_id).asset.text
		});
	}
}

/**
	Loaded from a Tiled map editor file
	Coordinates are 0-based x,y from the top-left
**/
/*
class Map {
	var tiles:Array<Tile>;

	public function new() {}

	public function load_from_json(json_str:String) {
	}

	public inline function get_tile(x:Int, y:Int) {
	}
}

class Tile {
}
*/
