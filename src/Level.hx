package;

import luxe.importers.tiled.TiledMap;

class Level {
	public static var tile_width:Float;
	public static var tile_height:Float;
	public static var tile_scale:Float;

	static var tiled_map:TiledMap;
	static var tiles:Array<Tile>;

	public static function load_json(json_str:String) {
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
	}
}

class Tile {
	var tilemap_tile:luxe.tilemaps.Tilemap.Tile;
	var tile_x(get, never):Int;
	var tile_y(get, never):Int;

// accessors
	public inline function get_tile_x() { return tilemap_tile.x; }
	public inline function get_tile_y() { return tilemap_tile.y; }
}
