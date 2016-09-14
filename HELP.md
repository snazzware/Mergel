# How to Play Mergel

>In the year 2317, Gold Stars are the most precious resource in the galaxy. They can only be created in specialized hex forges, by combining geometric shapes. You are a Merger, a skilled artisan tasked with the creation and harvesting of Gold Stars. Using the hex forge, you producing shapes with increasing number of sides, until finally the precious Gold Stars are ready to be harvested.

>Unfortunately for you, the Gel, a race of semi-intelligent jelly beans, have infested the shape silos, and have begun to infect shapes with their gelatinous anti-geometry...

Mergel is a puzzle game in which you place shapes to score points. Matching together
three or more of the same shape causes the shapes to "merge" together, forming
the next shape in the series. Triangles become squares, squares become pentagons, etc. The more
shapes which merge together to form a new one, the more points you earn!

TODO: video clip of shapes merging

Some shapes are "alive" (indicated by their eyes), and will move after every turn. If they
are unable to move, they will turn in to a regular piece (eyes go away) and won't move
any more. Shapes which are alive cannot be merged until they stop moving.

TODO: video clip of alive shape getting stuck

In addition to shapes, there are also Vanilla Gels. These gels start out alive, and
won't merge with other shapes. They will merge with each other, though. Three gels form
a Jelly Bean, and three Jelly Beans form a collectible.

TODO: video clip of gels merging

Collectibles are shapes which can be removed from the board by tapping on them, and are worth
lots of points. You can tell that a shape is collectible because it will rock back and forth.

TODO: video clip of collectible shapes

Wildcards will merge with two or more of any shape, even gel, as long as the shapes are not
alive. If a wildcard is placed on the board without merging, it becomes a Black Star.

Shapes, in order of merging, with base points
---------------------------------------------

| Shape | Base Point Value | Becomes |
|-------|------------------|---------|
|Triangle|10|Square|
|Square|100|Pentagon|
|Pentagon|500|Hexagon|
|Hexagon|1,000|Purple Star|
|Purple Star|10,000|Gold Star|
|Gold Star|25,000|Gold star (collectible)|
|Gold Star (collectible)|200,000|N/A|

Gels
----
1. Vanilla Gel (alive)
2. Vanilla Gel (not alive)
3. Vanilla Jelly Bean
4. Vanilla Jelly Beans (collectible)

Wildcard Preference
-------------------

If a wildcard is played, it will merge with the **highest value** option available. For example, if
a wildcard gets played touching two squares, but it is also touching two hexagons, it will merge with the
hexagons, since they have a higher value.
