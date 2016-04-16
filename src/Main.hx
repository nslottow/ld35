import luxe.Vector;
import luxe.Color;
import luxe.Sprite;

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

		// Load the default map
		var map_id = 'assets/maps/test_00.json';
		trace('Loading tiled map: $map_id');
		Level.load_json(Luxe.resources.text(map_id).asset.text);
		
		// Setup the debug toolbar
#if !release
		var map_file_input = js.Browser.document.getElementById('map-file-input');
		map_file_input.addEventListener('change', function(change_evt) {
			var file:js.html.File = change_evt.target.files[0];
			if (file != null) {
				var file_reader = new js.html.FileReader();
				file_reader.onload = function(load_evt) {
					var contents:String = load_evt.target.result;
					Level.load_json(contents);
					trace('loaded map from file: ${file.name}');
				};
				file_reader.readAsText(file);
			}
		});
#end
	}
}

