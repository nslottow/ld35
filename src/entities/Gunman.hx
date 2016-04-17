package entities;

import luxe.Entity;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.Color;
import luxe.Log.*;

import components.*;

typedef GunmanOptions = {
	> luxe.options.SpriteOptions,

	@:optional var face:String;
}

@:keep class Gunman extends Sprite {
	var tile_movement:TileMovement;
	var face:String;
	var facing_text:Text;

	public override function new(?_options:GunmanOptions) {
		_options.color = new Color(1.0, 1.0, 0.2, 0.8);
		_options.centered = false;

		super(_options);

		tile_movement = add(new TileMovement({name: 'tile_movement'}));
		tile_movement.walkable = true;

		face = def(_options.face, 'right');

		facing_text = new Text({
			point_size: 12,
			parent: this,
			align: TextAlign.center,
			align_vertical: TextAlign.center,
			pos: new Vector(size.x * 0.5, size.y * 0.5),
			depth: 200,
			text: face
		});
	}
}
