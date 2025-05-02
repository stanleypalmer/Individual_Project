#!/bin/bash --login

#SBATCH -p multicore             # AMD Genoa nodes
#SBATCH -n 16                     # Number of MPI tasks (match decomposeParDict)
#SBATCH -t 2-0                   # Runtime limit: 2 days

#SBATCH --output=mesh_one_%j.out
#SBATCH --error=mesh_one_%j.err

#SBATCH -J mesh_one

#SBATCH --mail-type=ALL
#SBATCH --mail-user=stanley.palmer@student.manchester.ac.uk

# Load OpenFOAM module
module load apps/gcc/openfoam/12
source $foamDotFile

# Go to job submission directory
cd $SLURM_SUBMIT_DIR

# Define the case names inside MeshOne
caseNames=("middle" "thin" "tall" "square")
meshFolder="MeshOne"

# Loop through each case
for caseName in "${caseNames[@]}"; do
    casePath="$meshFolder/$caseName"

    echo "---------------------------------------------"
    echo "Running case: $caseName in $meshFolder"
    echo "---------------------------------------------"

    cd "$casePath"

    # Decompose domain for parallel run
    echo "Decomposing case..."
    decomposePar -force > deco.log

    # Run simulation
    echo "Running solver..."
    mpirun -np 16 foamRun -parallel > run.log

    # Reconstruct solution
    echo "Reconstructing..."
    reconstructPar > rec.log

    # Optional cleanup
    echo "Cleaning processor directories..."
    rm -rf processor*

    echo "Finished $caseName in $meshFolder"
    echo "---------------------------------------------"

    # Go back to root submission directory
    cd "$SLURM_SUBMIT_DIR"
done
