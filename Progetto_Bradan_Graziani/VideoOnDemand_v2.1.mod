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
param Latency1;
param Latency2;
param MaxLatency;

# variables, non-negativity and binary constrains
var Flow1{Links} >=0, integer;		# three-indexed flow
var Flow2{Links} >=0, integer;		# three-indexed flow
var LinkActivation{Links} binary;

# data checks
check{i in Origins}: Loads[i] < 0;
check{i in Destinations}: Loads[i] > 0;
check{i in Transshipments}: Loads[i] == 0;

# objective function
minimize TotalFlowCosts: 
sum{(i,j) in Links} TravelCosts[i,j]*Flow1[i,j] + 
sum{(i,j) in Links} TravelCosts[i,j]*Flow2[i,j] + 
sum{(i,j) in Links} ActivationCosts[i,j]*LinkActivation[i,j];

# optimisation's constrains
subject to LinkingConstrain{(i,j) in Links}:
Flow1[i,j] <= Capacities[i,j]*LinkActivation[i,j];
subject to LinkingConstrain2{(i,j) in Links}:
Flow2[i,j] <= Capacities[i,j]*LinkActivation[i,j];
subject to OriginsConstrain{i in Origins}:
- sum{(i,j) in Links} Flow1[i,j] - sum{(i,j) in Links} Flow2[i,j] == Loads[i];
subject to TransshipmentsConstrain{i in Transshipments}:
sum{(k,i) in Links} Flow1[k,i] - sum{(i,j) in Links} Flow1[i,j]  == Loads[i];
subject to TransshipmentsConstrain2{i in Transshipments}:
sum{(k,i) in Links} Flow2[k,i] - sum{(i,j) in Links} Flow2[i,j]  == Loads[i];
subject to DestinationsConstrain{i in Destinations}:
sum{(k,i) in Links} Flow1[k,i] + sum{(k,i) in Links} Flow2[k,i] == Loads[i];

subject to ALinkConstrain{(i,j) in Links}:
# first flow must be <= the second flow
Flow1[i,j] <= Flow2[i,j];


