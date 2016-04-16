package entities;

import luxe.Entity;
import luxe.Input;

class PlayerController extends Entity {
	public static var instance:PlayerController;

	public var units:Array<PlayerUnit> = [];

	public override function new(?_options:luxe.options.EntityOptions) {
		super(_options);
		instance = this;
	}

	override function ondestroy() {
		instance = null;
	}

	override function onkeydown(e:KeyEvent) {
		// TODO: Make keys configurable
		var dx = 0;
		var dy = 0;

		switch (e.keycode) {
			case Key.left:
				dx = -1;
			case Key.right:
				dx = 1;
			case Key.up:
				dy = -1;
			case Key.down:
				dy = 1;
			default:
		}

		if (dx != 0 || dy != 0) {
			for (unit in units) {
				unit.tile_movement.move(dx, dy);
			}
		}
	}
}

