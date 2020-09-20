int[] score_system = {0, 40, 100, 300, 1200};

class Game {
    int dim;
    
    int [][] grid;
    color[][] color_grid;
    
    Piece actual_piece;
    Piece next_piece;
    Piece hold_piece;
    boolean has_hold_piece;
    
    boolean game_over;
    int lines_cleared;
    int score;
    
    Game () {
        dim = 40;
        
        grid = new int[20][10];
        for (int i = 0; i < 20; i++) {
            for (int j = 0; j < 10; j++) {
                grid[i][j] = 0;
            }
        }       
        
        color_grid = new color[20][10];
        for (int i = 0; i < 20; i++) {
            for (int j = 0; j < 10; j++) {
                color_grid[i][j] = colors[7];
            }
        }
        
        // generate first piece
        next_piece = new Piece ((int) random (7));
        
        // generate next piece
        set_piece ((int) random (7));
        
        has_hold_piece = false;
        game_over = false;
        
        lines_cleared = 0;
        score = 0;
    }
    
    void show () {
        // game board
        push ();
        
        stroke (0);
        translate (300, 25);
        strokeWeight (4);
        fill (255);
        rect (-1, -1, 402, 802);
        
        strokeWeight (1);
        stroke (0, 100);
        for (int i = 1; i < 10; i++) {
            line (i * dim, 0, i * dim, 800);
        }
        for (int i = 1; i < 20; i++) {
            line (0, i * dim, 400, i * dim);
        }
        
        stroke (0);
        strokeWeight (2);
        for (int i = 0; i < 20; i++) {
            for (int j = 0; j < 10; j++) {
                if (grid[i][j] == 1) {
                    fill (color_grid[i][j]);
                    rect (j * dim, i * dim, dim, dim);
                }
            }
        }
        
        pop ();
        
        // next piece
        push ();
        
        stroke (0);
        strokeWeight (4);
        fill (255);
        translate (750, 150);
        rect (0, 0, 200, 200);
        
        
        textAlign (CENTER);
        fill (0);
        text ("NEXT", 100, -40);
        
        strokeWeight (2);        
        fill (next_piece.col);
        if (next_piece.id == 0) {
            translate (dim / 2, dim);
        } else if (next_piece.id == 3) {
            translate (dim * 3 / 2, dim * 3 / 2);
        } else {
            translate (dim, dim * 3 / 2);
        }
        
        for (int i = 0; i < next_piece.n; i++) {
            for (int j = 0; j < next_piece.n; j++) {
                if (next_piece.blocks[i][j] == 1) {
                    rect (j * dim, i * dim, dim, dim);
                }
            }
        }
        
        pop ();
        
        // hold piece
        push ();
        
        stroke (0);
        strokeWeight (4);
        fill (255);
        translate (50, 150);
        rect (0, 0, 200, 200);
        
        textAlign (CENTER);
        fill (0);
        text ("HELD", 100, -40);
        
        if (has_hold_piece) {
            strokeWeight (2);        
            fill (hold_piece.col);
            if (hold_piece.id == 0) {
                translate (dim / 2, dim);
            } else if (hold_piece.id == 3) {
                translate (dim * 3 / 2, dim * 3 / 2);
            } else {
                translate (dim, dim * 3 / 2);
            }
            
            for (int i = 0; i < hold_piece.n; i++) {
                for (int j = 0; j < hold_piece.n; j++) {
                    if (hold_piece.blocks[i][j] == 1) {
                        rect (j * dim, i * dim, dim, dim);
                    }
                }
            }
        }
        
        pop ();
        
        // GUI
        push ();
        
        translate (740, 450);
        textSize (30);
        fill (0);
        text ("SCORE: " + score, 0, 0);
        text ("LINES: " + lines_cleared, 0, 60);
        
        pop ();
    }
    
    void set_piece (int id) {
        // check for complete lines
        int lines = 0;
        for (int i = 19; i >= 0; i--) {
            boolean all = true;
            for (int j = 0; j < 10; j++) {
                if (grid[i][j] == 0) {
                    all = false;
                    break;
                }
            }
            if (all) {
                lines++;
                
                // delete line
                for (int j = 0; j < 10; j++) {
                    for (int k = i; k > 0; k--) {
                        grid[k][j] = grid[k - 1][j];
                        color_grid[k][j] = color_grid[k - 1][j];
                    }
                    // generate new line
                    grid[0][j] = 0;
                    color_grid[0][j] = colors[7];
                }
                
                i++;
            }
        }
        lines_cleared += lines;
        score += score_system[lines];
        if (lines > 0) {
            println ("lines cleared:", lines_cleared, ", score:", score);
        }
        
        // set actual piece
        actual_piece = next_piece.clone ();
        
        // init piece
        next_piece = new Piece (id);
        
        if (collide ()) {
            game_over = true;
        }
        
        // draw
        for (int i = 0; i < actual_piece.n; i++) {
            for (int j = 0; j < actual_piece.n; j++) {
                int ny = i + actual_piece.pos_y, nx = j + actual_piece.pos_x;
                if (0 <= ny && ny < 20 && 0 <= nx && nx < 10) {
                    if (actual_piece.blocks[i][j] == 1) {
                        grid[ny][nx] = 1;
                        color_grid[ny][nx] = actual_piece.col;
                    }
                }
            }
        }
    }
    
    void hold () {
        clear_previous ();
        if (has_hold_piece) {
            int hold_id = hold_piece.id;
            hold_piece = new Piece (actual_piece.id);
            actual_piece = new Piece (hold_id);
        } else {
            hold_piece = new Piece (actual_piece.id);
            set_piece ((int) random (7));
            has_hold_piece = true;
        }
        apply_changes ();
    }
    
    boolean collide () {
        for (int i = 0; i < actual_piece.n; i++) {
            for (int j = 0; j < actual_piece.n; j++) {
                int ny = i + actual_piece.pos_y, nx = j + actual_piece.pos_x;
                if (ny > 19 || nx < 0 || nx > 9) {
                    if (actual_piece.blocks[i][j] == 1) {
                        return true;
                    }
                } else if (ny >= 0 && grid[ny][nx] == 1 && actual_piece.blocks[i][j] == 1) {
                    return true;
                }
            }
        }
        return false;
    }
    
    void clear_previous () {
        for (int i = 0; i < actual_piece.n; i++) {
            for (int j = 0; j < actual_piece.n; j++) {
                int ny = i + actual_piece.pos_y, nx = j + actual_piece.pos_x;
                if (ny >= 0 && nx < 20 && nx >= 0 && nx < 10) {
                    if (actual_piece.blocks[i][j] == 1) {
                        grid[i + actual_piece.pos_y][j + actual_piece.pos_x] = 0;
                        color_grid[i + actual_piece.pos_y][j + actual_piece.pos_x] = colors[7];
                    }
                }
            }
        }
    }
    
    void apply_changes () {
        for (int i = 0; i < actual_piece.n; i++) {
            for (int j = 0; j < actual_piece.n; j++) {
                int ny = i + actual_piece.pos_y, nx = j + actual_piece.pos_x;
                if (ny >= 0 && nx < 20 && nx >= 0 && nx < 10) {
                    if (actual_piece.blocks[i][j] == 1) {
                        grid[i + actual_piece.pos_y][j + actual_piece.pos_x] = 1;
                        color_grid[i + actual_piece.pos_y][j + actual_piece.pos_x] = actual_piece.col;
                    }
                }
            }
        }
    }
    
    boolean shift_down () {
        clear_previous ();
        actual_piece.pos_y++;
        
        if (collide ()) {
            actual_piece.pos_y--;
            apply_changes ();
            set_piece ((int) random (7));
            return false;
        } else {
            apply_changes ();
            return true;
        }
    }
    
    boolean shift_horizontal (int dir) {
        clear_previous ();
        actual_piece.pos_x += dir;
        
        if (collide ()) {
            actual_piece.pos_x -= dir;
            apply_changes ();
            return false;
        } else {
            apply_changes ();
            return true;
        }
    }
    
    boolean rotate_piece (int dir) {
        clear_previous ();
        if (dir == 1) {
            actual_piece.rotate_cl ();
        } else {
            actual_piece.rotate_acl();
        }
        
        if (collide ()) {
            if (dir == 1) {
                actual_piece.rotate_acl ();
            } else {
                actual_piece.rotate_cl();
            }
            apply_changes ();
            return false;
        } else {
            apply_changes ();
            return true;
        }
    }
    
    boolean move (int move_index) {
        switch (move_index) {
        case 0:
            return shift_down ();
        case 1:
            return shift_horizontal (1);
        case 2:
            return shift_horizontal (-1);
        case 3:
            return rotate_piece (1);
        case 4:
            return rotate_piece (-1);
        }
        return false;
    }
    
    Game clone () {
        Game new_game = new Game ();
        
        for (int i = 0; i < 20; i++) {
            new_game.grid[i] = grid[i].clone();
            new_game.color_grid[i] = color_grid[i].clone();
        }
        
        new_game.actual_piece = actual_piece.clone();
        new_game.next_piece = next_piece.clone();
        if (hold_piece != null) {
            new_game.hold_piece = hold_piece.clone();
        }
        
        new_game.has_hold_piece = has_hold_piece;
        
        new_game.game_over = game_over;
        new_game.lines_cleared = lines_cleared;
        new_game.score = score;
        
        return new_game;
    }
}
