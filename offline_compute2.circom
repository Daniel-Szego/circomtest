pragma circom 2.0.0;

/*Sample circuit to check if the minted token result mathes the computed result.*/  

template Offline_compute () {  

   // mint1, mint2, burn 

   // Declaration of signals.  
   // Declaration of signals.  
   //Declaration of signals
   signal input in1;
   signal input in2;
   signal output out;
   out <== in1 * in2; 



   // Calculate newbalance must match
//   newbalance1 === oldbalance1 + tokenstomint1;

   // get output 
//   out <== tokenstomint1;

   
}

component main {public [in1, in2]} = Offline_compute();

