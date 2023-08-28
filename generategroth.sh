#!/bin/bash
set -evx

echo "Generate proof Groth16";

export FILENAME=$1
echo "Filename: ${FILENAME}";

# compile
echo "Compile"
circom ${FILENAME}.circom --r1cs --wasm --sym --c

# --r1cs: rank one constraints
# --wasm: js folder containing the wasm
# --sym: symbolic file for debugging
# --c: cpp file

# copy compiled files
cp input.json ${FILENAME}_js
cp input.json ${FILENAME}_cpp
cp $FILENAME.r1cs ${FILENAME}_js
cp $FILENAME.r1cs ${FILENAME}_cpp


# generate witness from js
echo "Generate witness from js"

cd ${FILENAME}_js

node generate_witness.js ${FILENAME}.wasm input.json witness.wtns

# trusted setup phase1 - powers of tau

echo "Trusted setup phase1 - powers of tau"

snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# trusted setup phase2

echo "Trusted setup phase2"

snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

snarkjs groth16 setup ${FILENAME}.r1cs pot12_final.ptau ${FILENAME}_0000.zkey

snarkjs zkey contribute ${FILENAME}_0000.zkey ${FILENAME}_0001.zkey --name="1st Contributor Name" -v

# export the verification key

echo "Export the verification key"

snarkjs zkey export verificationkey ${FILENAME}_0001.zkey verification_key.json

# generate proof

echo "Generate proof"

snarkjs groth16 prove ${FILENAME}_0001.zkey witness.wtns proof.json public.json

# verify the proof

echo "Verify the proof"

snarkjs groth16 verify verification_key.json public.json proof.json

# solidity verfier contract

echo "Solidity verfier contract"

snarkjs zkey export solidityverifier ${FILENAME}_0001.zkey verifier.sol
