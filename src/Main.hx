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

	public static var tiled_map:TiledMap;

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

		// Load the default map
		var map_id = 'assets/maps/test_00.json';
		trace('Loading tiled map: $map_id');
		load_map_json(Luxe.resources.text(map_id).asset.text);
		
		// Setup the debug toolbar
#if !release
		trace('setting up debug toolbar');

		var map_file_input = js.Browser.document.getElementById('map-file-input');
		map_file_input.addEventListener('change', function(change_evt) {
			var file:js.html.File = change_evt.target.files[0];
			if (file != null) {
				var file_reader = new js.html.FileReader();
				file_reader.onload = function(load_evt) {
					var contents:String = load_evt.target.result;
					load_map_json(contents);
					trace('loaded map from file: ${file.name}');
				};
				file_reader.readAsText(file);
			}
		});
#end
	}

	static function load_map_json(json_str:String) {
		if (tiled_map != null) {
			// Destroy the old map
			tiled_map.destroy();
		}

		tiled_map = new TiledMap({
			asset_path: 'assets/maps',
			tiled_file_data: json_str,
			format: 'json',
		});

		// Scale the tilemap so the whole thing fits horizontally
		var scale:Float = w_points / (tiled_map.tile_width * tiled_map.width);
		tiled_map.display({
			scale: scale
		});
		trace('tile width = ${tiled_map.tile_width}, map scale = $scale, scaled tile width = ${tiled_map.tile_width * scale}');
	}
}

