class Piece {
    int pos_x, pos_y;
    int rotation_state;
    int id;
    int[][] blocks;
    color col;
    int n;
    
    int g_score;
    Piece previous;
    int previous_move;
    
    
    Piece (int shape) {
        id = shape;
        if (id == 3) {
            pos_x = 4;
            pos_y = 0;
        } else if (id == 0) {
            pos_x = 3;
            pos_y = -1;
        } else {
            pos_x = 3;
            pos_y = 0;
        }
        rotation_state = 0;
        
        n = shapes[id].length;
        blocks = new int[n][n];
        
        for (int i = 0; i < n; i++) {
            blocks[i] = shapes[id][i].clone();
        }
        col = colors[id];
        
        g_score = 1000000005;
    }
    
    void rotate_acl () {
        for (int y = 0; y < n / 2; y++) {
            for (int x = y; x < n - y - 1; x++) {
                int save = blocks[y][x];
                
                blocks[y][x] = blocks[x][n - y - 1];
                blocks[x][n - y - 1] = blocks[n - y - 1][n - x - 1];
                blocks[n - y - 1][n - x - 1] = blocks[n - x - 1][y];
                blocks[n - x - 1][y] = save;
            }
        }
        rotation_state = (rotation_state + 3) % 4;
    }
    
    void rotate_cl () {
        for (int y = 0; y < n / 2; y++) {
            for (int x = y; x < n - y - 1; x++) {
                int save = blocks[y][x];
                
                blocks[y][x] = blocks[n - x - 1][y];
                blocks[n - x - 1][y] = blocks[n - y - 1][n - x - 1];
                blocks[n - y - 1][n - x - 1] = blocks[x][n - y - 1];
                blocks[x][n - y - 1] = save;
            }
        }
        rotation_state = (rotation_state + 1) % 4;
    }
    
    boolean isEqual (Piece other) {
        return id == other.id && pos_x == other.pos_x && pos_y == other.pos_y && rotation_state == other.rotation_state;
    }
    
    Piece clone () {
        Piece new_piece = new Piece (id);
        new_piece.pos_x = pos_x;
        new_piece.pos_y = pos_y;
        new_piece.rotation_state = rotation_state;
        new_piece.col = col;
        new_piece.n = n;
        for (int i = 0; i < n; i++) {
            new_piece.blocks[i] = blocks[i].clone();
        }
        
        new_piece.g_score = g_score;
        new_piece.previous_move = previous_move;
        if (previous != null) {
            new_piece.previous = previous.clone ();
        }
        
        return new_piece;
    }
}
