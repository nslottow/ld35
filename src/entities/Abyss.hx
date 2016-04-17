package entities;

import luxe.Vector;
import luxe.Entity;
import luxe.Sprite;
import luxe.Color;

import components.*;

// TODO: since this is just a static tile, it doesn't have to extend Sprite,
// it can just extend Entity and we can have the tilemap generate a walkable tile
class Abyss extends Sprite {
	public var tile_movement:TileMovement;

	public override function new(?_options:luxe.options.SpriteOptions) {
		super(_options);

		// TMP: Need to get the sprite from the right atlas
		color = new Color(0, 0, 0);

		tile_movement = add(new TileMovement({name: 'tile_movement'}));
		tile_movement.walkable = true;

		// TODO: there could be a different event or a better name for bumped or moved onto
		events.listen('bumped_by', on_bumped_by);
	}

	function on_bumped_by(other_entity:Entity) {
		other_entity.events.fire('entered_abyss', this);
	}
}
