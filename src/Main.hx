import luxe.Vector;
import luxe.Color;
import luxe.Sprite;

import luxe.importers.tiled.TiledMap;

// TODO: Load tilemap

class Main extends luxe.Game {

	/** iPhone 6 point resolution */
	public static inline var w_points:Int = 375;
    public static inline var h_points:Int = 667;
	public static var screen_size_points:Vector = new Vector(w_points, h_points);

	public static var background:Sprite;
	public static var background_color:Color = new Color(0.2, 0.2, 0.2);

	override function config(config:luxe.AppConfig) {
		config.preload = {
			textures: [
				{ id: 'assets/maps/tilesets/8x8_dungeon.png' },
				{ id: 'assets/maps/tilesets/top_down_dungeon.png' },
				{ id: 'assets/maps/tilesets/packer_test.png' },
			],
			texts: [
				{ id: 'assets/maps/test_00.json' },
				{ id: 'assets/maps/test_01.json' },
			]
		};

		return config;
	}

	override function ready() {
		Luxe.camera.size = screen_size_points;
        Luxe.camera.size_mode = luxe.Camera.SizeMode.fit;

		background = new Sprite({
			size: screen_size_points,
			centered: false,
			color: background_color,
			no_scene: true
		});

		var map_id = 'assets/maps/test_00.json';
		trace('Loading tiled map: $map_id');

		var tiled_map = new TiledMap({
			asset_path: 'assets/maps',
			tiled_file_data: Luxe.resources.text(map_id).asset.text,
			format: 'json',
		});

		// Scale the tilemap so the whole thing fits horizontally
		var scale:Float = w_points / (tiled_map.tile_width * tiled_map.width);
		tiled_map.display({
			scale: scale
		});
		trace('tile width = ${tiled_map.tile_width}, map scale = $scale, scaled tile width = ${tiled_map.tile_width * scale}');

		var layer = tiled_map.layers_ordered[0];
		var tile = layer.tiles[0][0];

		tile.id = 0;
	}
}

