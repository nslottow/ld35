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
	public static var states:StateManager;

	override function config(config:luxe.AppConfig) {
		config.preload = {
			textures: [
				{ id: 'assets/maps/tilesets/8x8_dungeon.png' },
				{ id: 'assets/maps/tilesets/top_down_dungeon.png' },
				{ id: 'assets/maps/tilesets/packer_test.png' },
				{ id: 'assets/maps/tilesets/env.png' },
			],
			texts: [
				{ id: 'assets/maps/env_test_00.json' }, // default map
			]
		};

		return config;
	}

	override function ready() {
		// Setup the viewport
		Luxe.camera.size = screen_size_points;
        Luxe.camera.size_mode = luxe.Camera.SizeMode.fit;

		background = new Sprite({
			size: screen_size_points,
			centered: false,
			color: background_color,
			no_scene: true
		});

		// Setup the game states
		states = new StateManager();
		states.add(new states.Title({name: 'title'}));
		states.add(new states.LevelSelect({name: 'level_select'}));
		states.add(new states.Play({name: 'play'}));
		states.add(new states.MusicTest({name: 'music_test'}));

		// Setup the debug toolbar
#if !release
		var document = js.Browser.document;
		var storage = js.Browser.getLocalStorage();

		// Hook up the map loader
		{
			var map_file_input:js.html.InputElement = cast document.getElementById('map-file-input');

			var load_map = function() {
				var file:js.html.File = map_file_input.files[0];
				if (file != null) {
					var file_reader = new js.html.FileReader();
					file_reader.onload = function(load_evt) {
						var contents:String = load_evt.target.result;
						Level.load_json(contents);
						trace('loaded map from file: ${file.name}');
					};
					file_reader.readAsText(file);
				}
			};

			map_file_input.addEventListener('change', function(change_evt) {
				load_map();
			});

			var load_map_button = document.getElementById('load-map-button');
			load_map_button.addEventListener('click', function(click_evt) {
				load_map();
			});
		}


		// populate the state selector dropdown 
		{
			var state_selector:js.html.SelectElement = cast document.getElementById('state-selector-dropdown');
			var state_options = state_selector.options;

			for (state_name in states._states.keys()) {
				var elem:js.html.OptionElement = cast document.createElement('option');
				elem.label = state_name;
				elem.value = state_name;
				state_options.add(elem);
			}

			// Set the state based on the default in browser local storage
			var default_state = storage.getItem('debug_default_state');
			if (default_state == null) {
				default_state = 'play';
				storage.setItem('debug_default_state', default_state);
			}

			// Select the default state
			for (i in 0...state_options.length) {
				var option:js.html.OptionElement = cast state_options.item(i);
				if (option.value == default_state) {
					state_selector.selectedIndex = i;
				}
			}

			// Switch to the selected state when the selector changes
			state_selector.addEventListener('change', function(change_evt) {
				var i = state_selector.selectedIndex;
				var selected:js.html.OptionElement = cast state_selector.options.item(i);
				trace('state changing to "${selected.value}"');
				states.set(selected.value);
			});

			// Hook up the set default state button
			var default_button = document.getElementById('set-default-state-button');
			default_button.addEventListener('click', function(click_evt) {
				var i = state_selector.selectedIndex;
				var selected:js.html.OptionElement = cast state_selector.options.item(i);
				storage.setItem('debug_default_state', selected.value);
				trace('default state is now "${selected.value}"');
			});

			states.set(default_state);
		}

		//Music.init();
#else
		states.set('title');
#end
	}
}

