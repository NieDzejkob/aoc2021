USING: kernel sequences sequences.deep splitting math math.parser math.order math.matrices
       prettyprint accessors syntax make io.files io.encodings.utf8 arrays combinators
       assocs ;
IN: day5

! copied from the factor repo, because the last release was 3 years ago and I need this
: matrix-nth ( pair matrix -- elt )
    [ first2 swap ] dip nth nth ; inline
: matrix-set-nth ( obj pair matrix -- )
    [ first2 swap ] dip nth set-nth ; inline
: flatten1 ( obj -- seq )
    [
        [
            dup branch?
            [ [ dup branch? [ % ] [ , ] if ] each ] [ , ] if
        ]
    ] keep dup branch? [ drop f ] unless make ;

: matrix-change-nth ( ..a xy mat quot: ( ..a elt -- ..b newelt ) -- ..b )
  [ [ matrix-nth ] dip call ] 2keepd matrix-set-nth ; inline

: parse-point ( str -- point ) "," split1 [ string>number ] bi@ 2array ;
: parse-line ( str -- line ) " -> " split1 [ parse-point ] bi@ 2array ;

: largest ( nums -- max ) 0 [ max ] reduce ;
: bounds ( input -- width height )
    [ [ first ] map largest ]
    [ [ second ] map largest ]
    bi [ 1 + ] bi@ ;
: collate ( points -- mat )
  dup bounds 0 <matrix> [ [ [ 1 + ] matrix-change-nth ] curry each ] keep ;

: read-input ( filename -- lines ) utf8 file-lines [ parse-line ] map ;

: horizontal? ( p q -- t|f ) [ second ] bi@ = ;
: vertical? ( p q -- t|f ) [ first ] bi@ = ;

: uprange ( lo hi -- [lo;hi] ) [ min ] [ max ] 2bi
  1 + <iota> swap tail-slice ;
: range ( lo hi -- [lo;hi] ) [ uprange ] 2keep > [ <reversed> ] when ;
: xrange ( p q -- xrange ) [ first ] bi@ range ;
: yrange ( p q -- yrange ) [ second ] bi@ range ;
: hpoints ( p q -- points ) [ xrange ] keep second [ 2array ] curry map ;
: vpoints ( p q -- points ) [ yrange ] keep first [ swap 2array ] curry map ;
: diagpoints ( p q -- points ) [ xrange ] [ yrange ] 2bi zip ;

: ortho-points ( line -- points ) first2
  {
    { [ 2dup horizontal? ] [ hpoints ] }
    { [ 2dup vertical? ] [ vpoints ] }
    [ 2drop { } ]
  } cond ;

: line-points ( line -- points ) first2
  {
    { [ 2dup horizontal? ] [ hpoints ] }
    { [ 2dup vertical? ] [ vpoints ] }
    [ diagpoints ]
  } cond ;

: part1 ( lines -- n )
  [ ortho-points ] map flatten1 collate
  flatten [ 2 >= ] count ;

: part2 ( lines -- n )
  [ line-points ] map flatten1 collate
  flatten [ 2 >= ] count ;

: handle-input ( fname -- )
  read-input [ part1 . ] [ part2 . ] bi ;

"input-example.txt" handle-input
"input.txt" handle-input
