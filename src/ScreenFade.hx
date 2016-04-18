package;

import luxe.Color;
import luxe.Vector;
import luxe.Sprite;
import luxe.tween.Actuate;

class ScreenFade {
	static var black_overlay:Sprite;
	static var white_overlay:Sprite;

	static var tween_target:Dynamic;

	static var black:Color = new Color(0, 0, 0, 1);
	static var white:Color = new Color(1, 1, 1, 1);
	static var clear:Color = new Color(0, 0, 0, 0);

	public static function init() {
		black_overlay = new Sprite({
			size: Main.screen_size_points,
			centered: false,
			color: black.clone(),
			no_scene: true,
			depth: 1000,
			visible: false
		});

		white_overlay = new Sprite({
			size: Main.screen_size_points,
			centered: false,
			color: white.clone(),
			no_scene: true,
			depth: 1000,
			visible: false
		});
	}

	public static function fade_to_black(duration:Float, overwrite:Bool=true) {
		var overlay_color = black_overlay.color;
		overlay_color.a = 0.0;

		black_overlay.visible = true;
		overlay_color.tween(duration, {a: 1.0}, overwrite);
	}

	public static function fade_from_black(duration:Float, overwrite:Bool=true) {
		var overlay_color = black_overlay.color;
		overlay_color.a = 1.0;

		black_overlay.visible = true;
		overlay_color.tween(duration, {a: 0}, overwrite)
			.onComplete(function() {
				black_overlay.visible = false;
			});
	}
}
