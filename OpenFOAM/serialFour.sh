#!/bin/bash --login

#SBATCH -p serial
#SBATCH -n 1                     # Number of MPI tasks
#SBATCH -t 2-0                   # Runtime limit: 2 days

#SBATCH --output=single_FOUR_%j.out
#SBATCH --error=single_FOUR_%j.err

#SBATCH -J serial_FOUR

#SBATCH --mail-type=ALL
#SBATCH --mail-user=stanley.palmer@student.manchester.ac.uk

# Load OpenFOAM module
module load apps/gcc/openfoam/12
source $foamDotFile

# Go to the directory this job was submitted from
cd $SLURM_SUBMIT_DIR

# ------------- CUSTOMISE THIS LINE ----------------
CASE_PATH="SerialTest/middle_FOUR"   # ?? Set your desired folder here
# --------------------------------------------------

echo "---------------------------------------------"
echo "Running case at path: $CASE_PATH"
echo "---------------------------------------------"

cd "$CASE_PATH"

# Run simulation
echo "Running solver..."
blockMesh
checkMesh
foamRun > run.log

echo "Finished simulation for $CASE_PATH"
