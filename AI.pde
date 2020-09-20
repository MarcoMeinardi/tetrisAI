class AI {
    Game game;
    IntList best_path;
    Piece best_ending_state;
    int best_score;
    int path_ind;
    
    AI () {
        game = new Game ();
        path_ind = -1;
    }
    
    void play () {
        if (path_ind == -1) {
            game.move (0);
            dijkstra ();
            best_path = new IntList ();
                
            while (best_ending_state != null) {
                best_path.append (best_ending_state.previous_move);
                best_ending_state = best_ending_state.previous;
            }
            path_ind = best_path.size() - 1;
        } else {
            game.move (best_path.get (path_ind));
            path_ind--;
        }
            
        game.show ();
    }
    
    // dijkstra algorithm to find optimal moves to reach every ending state and save the best one
    void dijkstra () {
        Game cp = game.clone ();
        cp.clear_previous ();
        
        ArrayList <Piece> open   = new ArrayList <Piece> ();
        ArrayList <Piece> closed = new ArrayList <Piece> ();
        
        Piece current = new Piece (cp.actual_piece.id);
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
            cp.actual_piece = current.clone();
            
            // check if ending state
            cp.actual_piece.pos_y++;
            if (cp.collide ()) {
                // found one ending state
                // if better then actual best set new best
                
                best_ending_state = current.clone ();
                
                return;
            }
            cp.actual_piece.pos_y--;
            
            closed.add (current.clone ());
            delete (open, current);
            
            for (int i = 0; i < 5; i++) {
                if (!fake_move (cp, i)) {
                    Piece next = cp.actual_piece.clone ();
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
                undo_fake_move (cp, i);
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
        
        return state.collide ();
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
