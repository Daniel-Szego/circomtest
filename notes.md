# compile
circom offline_compute.circom --r1cs --wasm --sym --c

# --r1cs: rank one constraints
# --wasm: js folder containing the wasm
# --sym: symbolic file for debugging
# --c: cpp file

cp input.json offline_compute_js
cp input.json offline_compute_cpp
cp offline_compute.r1cs offline_compute_js
cp offline_compute.r1cs offline_compute_cpp


# generate witness from js
cd offline_compute_js

node generate_witness.js offline_compute.wasm input.json witness.wtns

# trusted setup phase1 - powers of tau

snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# trusted setup phase2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

snarkjs groth16 setup offline_compute.r1cs pot12_final.ptau offline_compute_0000.zkey

snarkjs zkey contribute offline_compute_0000.zkey offline_compute_0001.zkey --name="1st Contributor Name" -v

# export the verification key
snarkjs zkey export verificationkey offline_compute_0001.zkey verification_key.json

# generate proof
snarkjs groth16 prove offline_compute_0001.zkey witness.wtns proof.json public.json

# verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# solidity verfier contract
snarkjs zkey export solidityverifier offline_compute_0001.zkey verifier.sol
