# row and column indexes
set Vertixes;
set Origins within Vertixes;
set Destinations within Vertixes;
set Transshipments within Vertixes;
set Links within {Vertixes cross Vertixes};

# "data structures"
param ActivationCosts{Links} >=0;
param TravelCosts{Links} >=0;
param Capacities{Links} >0;
param Loads{Vertixes};
param Latency1A;
param Latency2A;
param Latency1C;
param Latency2C;
param MaxLatency;

# variables, non-negativity and binary constrains
var Flow1{Links, Origins} >=0, integer;		# three-indexed flow
var Flow2{Links, Origins} >=0, integer;		# three-indexed flow
var LinkActivation{Links} binary;

# data checks
check{i in Origins}: Loads[i] < 0;
check{i in Destinations}: Loads[i] > 0;
check{i in Transshipments}: Loads[i] == 0;

# objective function
minimize TotalFlowCosts: 
sum{(i,j) in Links, o in Origins} TravelCosts[i,j]*Flow1[i,j,o] + 
sum{(i,j) in Links, o in Origins} TravelCosts[i,j]*Flow2[i,j,o] + 
sum{(i,j) in Links} ActivationCosts[i,j]*LinkActivation[i,j];

# optimisation's constrains
subject to LinkingConstrain{(i,j) in Links, o in Origins}:
Flow1[i,j,o] <= Capacities[i,j]*LinkActivation[i,j];
subject to LinkingConstrain2{(i,j) in Links, o in Origins}:
Flow2[i,j,o] <= Capacities[i,j]*LinkActivation[i,j];
subject to OriginsConstrain{i in Origins}:
- sum{(i,j) in Links} Flow1[i,j,i] - sum{(i,j) in Links} Flow2[i,j,i] == Loads[i];
subject to TransshipmentsConstrain{i in Transshipments, o in Origins}:
sum{(k,i) in Links} Flow1[k,i,o] - sum{(i,j) in Links} Flow1[i,j,o]  == Loads[i];
subject to TransshipmentsConstrain2{i in Transshipments, o in Origins}:
sum{(k,i) in Links} Flow2[k,i,o] - sum{(i,j) in Links} Flow2[i,j,o]  == Loads[i];
subject to DestinationsConstrain{i in Destinations}:
sum{(k,i) in Links, o in Origins} Flow1[k,i,o] + sum{(k,i) in Links, o in Origins} 
Flow2[k,i,o] == Loads[i];

# first flow must be <= the second flow
subject to ALinkConstrain{(i,j) in Links}:
Flow1[i,j,'A'] <= Flow2[i,j,'A'];
# first flow must be <= the second flow
subject to CLinkConstrain{(i,j) in Links}:
Flow1[i,j,'C'] <= Flow2[i,j,'C'];





