class AI {
    Game game;
    IntList best_path;
    Piece best_ending_state;
    int best_score;
    int path_ind;
    
    AI () {
        game = new Game ();
        
        get_moves ();
    }
    
    void play () {
        if (!game.game_over) {
            if (path_ind == -1) {
                game.move (0);
                get_moves ();
            } else {
                game.move (best_path.get (path_ind));
                path_ind--;
            }
        }
        game.show ();
    }
    
    void get_moves () {
        best_score = -1000000005;
        Game cp = game.clone ();
        dijkstra (cp);
        int actual_best = best_score;
        cp.hold ();
        dijkstra (cp);
        if (actual_best < best_score) {
            game.hold ();
        }
        best_path = new IntList ();
            
        while (best_ending_state != null) {
            best_path.append (best_ending_state.previous_move);
            best_ending_state = best_ending_state.previous;
        }
        path_ind = best_path.size() - 2;
    }
    
    // dijkstra algorithm to find optimal moves to reach every ending state and save the best one
    void dijkstra (Game state) {
        state.clear_previous ();
        
        ArrayList <Piece> open   = new ArrayList <Piece> ();
        ArrayList <Piece> closed = new ArrayList <Piece> ();
        
        Piece current = new Piece (state.actual_piece.id);
        current.g_score = 0;
        open.add (current.clone ());
        
        while (!open.isEmpty ()) {
            // get state with lowest g score
            int best_index = 0;
            for (int i = 1; i < open.size(); i++) {
                if (open.get (best_index).g_score > open.get (i).g_score) {
                    best_index = i;
                }
            }
            current = open.get (best_index).clone ();
            state.actual_piece = current.clone();
            
            // check if ending state
            state.actual_piece.pos_y++;
            if (state.collide ()) {
                // ending state found
                // if better then actual best set new best
                
                state.actual_piece.pos_y--;
                int actual_score = get_score (state.clone ());
                if (actual_score > best_score) {
                    //println ("score:", actual_score);
                    best_ending_state = current.clone ();
                    best_score = actual_score;
                }
            } else {
                state.actual_piece.pos_y--;
            }
            
            closed.add (current.clone ());
            delete (open, current);
            
            for (int i = 0; i < 5; i++) {
                if (fake_move (state, i)) {
                    Piece next = state.actual_piece.clone ();
                    if (contains (closed, next) == null) {
                        int g_attempt = current.g_score + 1;
                        Piece find = contains(open, next);
                        if (find == null) {
                            next.g_score = g_attempt;
                            next.previous = current.clone ();
                            next.previous_move = i;
                            open.add (next.clone ());
                        } else if (find.g_score > g_attempt) {
                            find.g_score = g_attempt;
                            find.previous = current.clone ();
                            find.previous_move = i;
                        }
                    }
                }
                undo_fake_move (state, i);
            }
        }
    }
    
    boolean fake_move (Game state, int index) {
        switch (index) {
        case 0:
            state.actual_piece.pos_y++;
            break;
        case 1:
            state.actual_piece.pos_x++;
            break;
        case 2:
            state.actual_piece.pos_x--;
            break;
        case 3:
            state.actual_piece.rotate_cl ();
            break;
        case 4:
            state.actual_piece.rotate_acl ();
            break;
        }
        
        return !state.collide ();
    }
    void undo_fake_move (Game state, int index) {
        switch (index) {
        case 0:
            state.actual_piece.pos_y--;
            break;
        case 1:
            state.actual_piece.pos_x--;
            break;
        case 2:
            state.actual_piece.pos_x++;
            break;
        case 3:
            state.actual_piece.rotate_acl ();
            break;
        case 4:
            state.actual_piece.rotate_cl ();
            break;
        }
    }
    
    int get_score (Game state) {
        int score = 0;
        
        // height
        int max_height = -1;
        for (int i = 0; i < state.actual_piece.n && max_height == -1; i++) {
            for (int j = 0; j < state.actual_piece.n; j++) {
                if (state.actual_piece.blocks[i][j] == 1) {
                    max_height = i;
                    break;
                }
            }
        }
        score += state.actual_piece.pos_y + max_height;

        
        
        
        // holes
        int previous_holes = count_holes (state);

        // check if the actual piece clear lines
        int actual_lines = state.lines_cleared;
        state.shift_down ();
        state.clear_previous ();
        
        int actual_holes = count_holes (state);
        int new_holes = actual_holes - previous_holes;
        score -= new_holes * 2;
        
        score += (state.lines_cleared - actual_lines);
        
        // bumpiness
        int bumpiness = 0;
        
        int prev;
        int actual;
        for (prev = 0; prev < 20; prev++) {
            if (state.grid[prev][0] == 1) {
                break;
            }
        }
        for (int j = 1; j < 10; j++) {
            for (actual = 0; actual < 20; actual++) {
                if (state.grid[actual][j] == 1) {
                    break;
                }
            }
            bumpiness += abs (prev - actual);
            prev = actual;
        }
        
        score -= bumpiness / 2;
        
        
        return score;
    }
    
    int count_holes (Game state) {
        int holes = 0;
        for (int i = 0; i < 20; i++) {
            for (int j = 0; j < 10; j++) {
                if (state.grid[i][j] == 1) {
                    int y = i + 1;
                    while (y < 20 && state.grid[y][j] == 0) {
                        holes++;
                        y++;
                    }
                }
            }
        }
        
        return holes;
    }
}

Piece contains (ArrayList <Piece> list, Piece target) {
    for (Piece p : list) {
        if (p.isEqual (target)) {
            return p;
        }
    }
    return null;
}

void delete (ArrayList <Piece> list, Piece target) {
    for (int i = 0; i < list.size(); i++) {
        if (list.get (i).isEqual (target)) {
            for (; i < list.size() - 1; i++) {
                list.set (i, list.get (i + 1));
            }
            list.remove (i);
        }
    }
}
