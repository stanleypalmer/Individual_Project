#!/bin/bash

# Geometry definitions
declare -A WIDTHS=(   [middle]=0.3362    [square]=0.1681    [tall]=0.08405   [thin]=1.3448 )
declare -A HEIGHTS=(  [middle]=0.1681    [square]=0.1681    [tall]=0.1681    [thin]=0.1681 )

MESH_FOLDERS=(MeshOne MeshTwo MeshThree MeshFour)
CELL_COUNTS=(12500 25000 50000 100000)

for i in ${!MESH_FOLDERS[@]}; do
    FOLDER=${MESH_FOLDERS[$i]}
    TOTAL_CELLS=${CELL_COUNTS[$i]}
    echo "Generating mesh level: $FOLDER with $TOTAL_CELLS cells per case"

    for case in middle square tall thin; do
        WIDTH=${WIDTHS[$case]}
        HEIGHT=${HEIGHTS[$case]}

        # Calculate aspect ratio
        RATIO=$(echo "$WIDTH / $HEIGHT" | bc -l)

        # Compute NX and NY such that NX * NY = TOTAL_CELLS and matches geometry ratio
        NX=$(printf "%.0f" $(echo "sqrt($TOTAL_CELLS * $RATIO)" | bc -l))
        NY=$(( TOTAL_CELLS / NX ))
        ACTUAL_TOTAL=$(( NX * NY ))

        # Adjust depth so that depth = HEIGHT / NY, making cell size in Z = Y
        CELL_DEPTH=$(echo "$HEIGHT / $NY" | bc -l)
        DEPTH=$CELL_DEPTH

        CASE_DIR="$FOLDER/$case"
        mkdir -p $CASE_DIR

        # Copy base case files
        cp -r baseCase/constant $CASE_DIR/
        cp -r baseCase/system $CASE_DIR/
        cp -r baseCase/0 $CASE_DIR/

        mkdir -p $CASE_DIR/constant/polyMesh

        # Create blockMeshDict
        cat > $CASE_DIR/system/blockMeshDict <<EOF
FoamFile
{
    format      ascii;
    class       dictionary;
    object      blockMeshDict;
}
convertToMeters 1;

vertices
(
    (0 0 0)
    ($WIDTH 0 0)
    ($WIDTH $HEIGHT 0)
    (0 $HEIGHT 0)
    (0 0 $DEPTH)
    ($WIDTH 0 $DEPTH)
    ($WIDTH $HEIGHT $DEPTH)
    (0 $HEIGHT $DEPTH)
);

blocks
(
    hex (0 1 2 3 4 5 6 7) ($NX $NY 1) simpleGrading (1 1 1)
);

edges
(
);

boundary
(
    floor
    {
        type wall;
        faces
        (
            (1 5 4 0)
        );
    }
    ceiling
    {
        type wall;
        faces
        (
            (3 7 6 2)
        );
    }
    fixedWalls
    {
        type wall;
        faces
        (
            (0 4 7 3)
            (2 6 5 1)
        );
    }
    frontAndBack
    {
        type empty;
        faces
        (
            (0 3 2 1)
            (4 5 6 7)
        );
    }

);
EOF

        # Run blockMesh 
        blockMesh -case $CASE_DIR > /dev/null

        # Create the .foam file
        echo "$CASE_DIR" > $CASE_DIR/$case.foam

        echo "  > Created $case in $FOLDER with mesh ${NX} x ${NY} x 1 = $ACTUAL_TOTAL cells (aspect ratio: $(printf "%.2f" $RATIO), depth: $(printf "%.6f" $DEPTH))"
    done
done
