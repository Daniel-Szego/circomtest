#!/bin/bash
set -evx

#detailed docs: https://github.com/iden3/snarkjs#7-prepare-phase-2

echo "Generate proof Plonk";

export FILENAME=$1
echo "Filename: ${FILENAME}";

# compile
echo "Compile"
circom ${FILENAME}.circom --r1cs --wasm --sym --c

# --r1cs: rank one constraints
# --wasm: js folder containing the wasm
# --sym: symbolic file for debugging
# --c: cpp file

# view information on the circuit
echo "View information on the circuit"
snarkjs r1cs info ${FILENAME}.r1cs

# copy setup power of tau
cp preparedtau/pot14_0000.ptau ${FILENAME}_js/pot14_0000.ptau
cp preparedtau/pot14_0001.ptau ${FILENAME}_js/pot14_0001.ptau
cp preparedtau/pot14_beacon.ptau ${FILENAME}_js/pot14_beacon.ptau
cp preparedtau/pot14_final.ptau ${FILENAME}_js/pot14_final.ptau

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

#snarkjs powersoftau new bn128 14 pot14_0000.ptau -v

#snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v

# trusted setup phase2

echo "Trusted setup phase2 power of tau"

#snarkjs powersoftau prepare phase2 pot14_0001.ptau pot14_final.ptau -v

#snarkjs powersoftau contribute pot14_0001.ptau pot14_0002.ptau --name="Second contribution" -v -e="some random text"

#snarkjs powersoftau export challenge pot14_0002.ptau challenge_0003
#snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="some random text"
#snarkjs powersoftau import response pot14_0002.ptau response_0003 pot14_0003.ptau -n="Third contribution name"

# verify the protocol
echo "Verify the protocol"
#snarkjs powersoftau verify pot14_0003.ptau

# random beacon
echo "Random beacon"
#snarkjs powersoftau beacon pot14_0003.ptau pot14_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

# Prepare phase 2
echo "Random beacon"
#snarkjs powersoftau prepare phase2 pot14_beacon.ptau pot14_final.ptau -v

# Verify final
echo "Verify final power of tau"
#snarkjs powersoftau verify pot14_final.ptau


#setup plonk
echo "setup plonk"
snarkjs plonk setup ${FILENAME}.r1cs pot14_final.ptau ${FILENAME}_final.zkey

#export the verification key
echo "export the verification key"
snarkjs zkey export verificationkey ${FILENAME}_final.zkey verification_key.json

# create proof plonk
echo "create proof plonk"
snarkjs plonk prove ${FILENAME}_final.zkey witness.wtns proof.json public.json

# verify proof
echo "verify proof"
snarkjs plonk verify verification_key.json public.json proof.json

# turn verifier into smart contract
echo "turn verifier into smart contract"
snarkjs zkey export solidityverifier ${FILENAME}_final.zkey verifier.sol

# simulate verification call
echo "simulate verification call"
snarkjs zkey export soliditycalldata public.json proof.json


