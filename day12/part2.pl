file_contents(File, Contents) :-
    open(File, read, Fd),
    read_string(Fd, _, Contents).

file_lines(File, Lines) :-
    file_contents(File, Contents),
    split_string(Contents, "\n", "\n", Lines).

parse_line(Line, Edge) :-
    split_string(Line, "-", "", [A, B]),
    Edge = edge(A, B).

edges(File, Edges) :-
    file_lines(File, Lines),
    maplist(parse_line, Lines, Edges).

connected(Edges, A, B) :- member(edge(A, B), Edges).
connected(Edges, A, B) :- member(edge(B, A), Edges).

may_repeat(A) :- string_upper(A, A).

fresh(A, MayRepeat, MayRepeat, _) :- may_repeat(A), !.
fresh(A, MayRepeat, MayRepeat, Path) :- not(member(A, Path)), !.
fresh(A, A, usedup, Path) :- dif(A, "start"), dif(A, "end").

path(_, P, P, PathEnd, MayRepeat, [P|PathEnd]) :- fresh(P, MayRepeat, _, PathEnd).
path(Edges, From, Mid, PathEnd, MayRepeat, Result) :-
    connected(Edges, P, Mid),
    fresh(Mid, MayRepeat, UsedUp, PathEnd),
    path(Edges, From, P, [Mid|PathEnd], UsedUp, Result).

count_paths(Edges, Count) :-
    aggregate_all(count, path(Edges, "start", "end", [], _, _), Count).

solve_file(File, Count) :-
    edges(File, Edges),
    count_paths(Edges, Count).
