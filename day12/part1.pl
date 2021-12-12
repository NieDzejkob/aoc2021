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

fresh(A, _) :- may_repeat(A), !.
fresh(A, Path) :- not(member(A, Path)).

path(_, P, P, PathEnd, [P|PathEnd]) :- fresh(P, PathEnd).
path(Edges, From, Mid, PathEnd, Result) :-
    connected(Edges, P, Mid),
    fresh(Mid, PathEnd),
    path(Edges, From, P, [Mid|PathEnd], Result).

count_paths(Edges, Count) :-
    aggregate_all(count, path(Edges, "start", "end", [], _), Count).

solve_file(File, Count) :-
    edges(File, Edges),
    count_paths(Edges, Count).
