package states;

import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.Sprite;

import luxe.Parcel;
import luxe.Input;

class LevelSelect extends luxe.States.State {
	var banner:Sprite;
	var buttons:Array<LevelSelectButton>;

	override function onenter<T>(_:T) {
		var parcel = new Parcel({
            jsons: [
				{ id:'assets/map_list.json' },
			],
            textures: [
				{ id: 'assets/textures/ui_stageselect_background.png' },
                { id: 'assets/textures/ui_stageselect_button.png' },
            ],
			fonts:[
				{ id: 'assets/fonts/font0.fnt' }
			],
			oncomplete: on_loaded
        });

		parcel.load();

		buttons = [];
	}

	function on_loaded(_) {
		var map_list:Array<String> = Luxe.resources.json('assets/map_list.json').asset.json;

		{
			banner = new Sprite({
				pos: Vector.Multiply(Main.screen_size_points, 0.5),
				size: new Vector(Main.w_points, Main.w_points),
				texture: Luxe.resources.texture('assets/textures/ui_stageselect_background.png'),
				depth: -1
			});

			var button_size = 48;
			var button_size_vector = new Vector(button_size, button_size);

			var button_font = Luxe.resources.font('assets/fonts/font0.fnt');
			var button_font_size = 24;
			var button_label_pos = new Vector(button_size * 0.5, button_size * 0.4);

			var buttons_left_x = 20;
			var buttons_top_y = Main.h_points * 0.5 - button_size;

			for (i in 0...map_list.length) {
				var col = i % 7;
				var row = Math.floor(i / 7);

				var button = new LevelSelectButton({
					pos: new Vector(button_size * col + buttons_left_x, button_size * row + buttons_top_y),
					size: button_size_vector,
					texture: Luxe.resources.texture('assets/textures/ui_stageselect_button.png'),
					centered: false
				});

				button.map_index = i;

				var label = new Text({
					parent: button,
					pos: button_label_pos,
					text: '${i + 1}',
					align: TextAlign.center,
					align_vertical: TextAlign.center,
					font: button_font,
					point_size: button_font_size
				});

				buttons.push(button);
			}
		}
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}

	override function ontouchdown(e:TouchEvent) {
		var screen_pos = new Vector(e.x * Luxe.screen.w, e.y * Luxe.screen.h);
		var world_pos = Luxe.camera.screen_point_to_world(screen_pos);

		for (button in buttons) {
			if (button.point_inside(world_pos)) {
				trace('clicked map: ${button.map_index}');
				ScreenFade.fade_to_black(0.7);
				Luxe.timer.schedule(0.9, function() {
					Main.states.set('play', button.map_index);
					ScreenFade.fade_from_black(0.7);
				});
				return;
			}
		}
	}
}

class LevelSelectButton extends Sprite {
	public var map_index:Int;
}
