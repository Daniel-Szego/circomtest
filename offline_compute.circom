pragma circom 2.1.6;

/*Sample circuit to check if the minted token result mathes the computed result.*/  

template Mint() {

   // newbalance = oldbalance + mintparam1 * mintparam2 + mintparam3

   // Declaration of signals.  
   signal input mintparam1;  
   signal input mintparam2;  
   signal input mintparam3;
   signal input oldbalance;
   signal input newbalance;
   signal output tokenstomint;

   // Calculate tokenstomint
   tokenstomint <== mintparam1 * mintparam2 + mintparam3;  

   // Calculate newbalance must match
   newbalance === oldbalance + tokenstomint;

}

template Burn() {

   // newbalance =  burnparam1 * burnparam2 + burnparam3

   // Declaration of signals.  
   signal input burnparam1;  
   signal input burnparam2;  
   signal input burnparam3;
   signal input oldbalance;
   signal input newbalance;
   signal output tokenstoburn;

   // Calculate tokenstoburn
   tokenstoburn <== burnparam1 * burnparam2 + burnparam3;  

   // calculate new balance must match
   newbalance + tokenstoburn === oldbalance;

}

template Offline_compute () {  

   // mint1, mint2, burn 

   // Declaration of signals.  
   signal input mintparam11;  
   signal input mintparam12;  
   signal input mintparam13;
   signal input oldbalance1;
   signal input newbalance1;
   signal output tokenstomint1;

   signal input mintparam21;  
   signal input mintparam22;  
   signal input mintparam23;
   signal input oldbalance2;
   signal input newbalance2;
   signal output tokenstomint2;

   signal input burnparam31;  
   signal input burnparam32;  
   signal input burnparam33;
   signal input oldbalance3;
   signal input newbalance3;
   signal output tokenstoburn1;

   // initialize subcircuits
   component mint1 = Mint();
   component mint2 = Mint();
   component burn = Burn();

   // set wire mint1
   mint1.mintparam1 <== mintparam11;  
   mint1.mintparam2 <== mintparam12;  
   mint1.mintparam3 <== mintparam13;  
   mint1.oldbalance <== oldbalance1;  
   mint1.newbalance <== newbalance1;  
   tokenstomint1 <== mint1.tokenstomint;

   // set wire mint2
   mint2.mintparam1 <== mintparam21;  
   mint2.mintparam2 <== mintparam22;  
   mint2.mintparam3 <== mintparam23;  
   mint2.oldbalance <== oldbalance2;  
   mint2.newbalance <== newbalance2;  
   tokenstomint2 <== mint2.tokenstomint;
   
   // set wire burn
   burn.burnparam1 <== burnparam31;  
   burn.burnparam2 <== burnparam32;  
   burn.burnparam3 <== burnparam33;  
   burn.oldbalance <== oldbalance3;  
   burn.newbalance <== newbalance3;  
   tokenstoburn1 <== burn.tokenstoburn;
   
}

 component main {public [
   mintparam11,  
   mintparam12,  
   mintparam13,
   oldbalance1,
   newbalance1,
   mintparam21,  
   mintparam22, 
   mintparam23,
   oldbalance2,
   newbalance2,
   burnparam31,  
   burnparam32,  
   burnparam33,
   oldbalance3,
   newbalance3
 ]} = Offline_compute();
