import java.util.*;

AI game;

void setup () {
    size (1000, 850);
    game = new AI ();
    textFont (createFont ("Bungee Inline", 50));
    frameRate (10000);
}
void draw () {
    if (game.game.game_over) {
        noLoop ();
        println ("game over");
    }
    background (230);
    game.play ();
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
