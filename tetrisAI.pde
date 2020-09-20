<<<<<<< HEAD
=======
// change

import java.util.*;

>>>>>>> c86c06610a318dbfeca29e5495bbdb621c4fa3a3
AI game;

void setup () {
    size (1000, 850);
    game = new AI ();
    textFont (createFont ("Bungee Inline", 50));
    game.dijkstra ();
    frameRate (100000);
}
void draw () {
    println (frameRate);
    if (game.game.game_over) {
        noLoop ();
        println ("game over");
    }
    background (230);
    game.play ();
    game.dijkstra ();
}
/*
void keyPressed () {
    if (keyCode == LEFT) {
        game.shift_horizontal (-1);
    } else if (keyCode == RIGHT) {
        game.shift_horizontal ( 1);
    } else if (keyCode == DOWN) {
        game.shift_down ();
    } else if (key == 'z' || key == 'Z') {
        game.rotate_piece (-1);
    } else if (key == 'x' || key == 'X') {
        game.rotate_piece (1);
    } else if (key == ' ') {
        game.hold ();
    }
}
*/
