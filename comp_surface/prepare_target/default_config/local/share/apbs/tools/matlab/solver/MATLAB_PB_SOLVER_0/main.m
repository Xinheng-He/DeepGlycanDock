clear
clc

%% MATLAB version of the PB solver

% THIS CODE IS BASED ON THE HOLST ARTICLE AND THE APBS ALGORITHM. IT
% BASICALLY SOLVES THE LINEARIZED PB EQUATION AND THEN SAVE THE SOLUTION IN DX FORMAT. 
% FOR TESTING PORPUSE, IT ALSO GENERATES TRHEE PLOTS, ONE CORRESPONDING 
% TO THE ABSOLUTE ERROR BETWEEN APBS AND MATLAB SOLUTIONS, ANOTHER FOR THE APBS SOLUTION AND THE OTHER FOR
% THE MATLAB SOLUTION FOR THE ELECTROSTATIC POTENTIAL.

% WARNING!!!!!!!!!!!!!!! BEFORE USING IT: 

% FIRST STEP:

% YOU MUST CREATE A FOLDER TERMED "examples". IT MUST CONTAIN THE FOLLOWING
% FILES:
% THE PQR FILE.
% THE THREE DX FILES CORRESPONDING TO THE SHIFTED DIELECTRIC COEFFICIENTS
% AS GENERATED BY THE APBS CODE.
% THE DX FILE CORRESPONDING TO THE CHARGE DISTRIBUTION AS GENERATED BY THE
% APBS CODE.
% THE DX FILE CORRESPONDING TO THE KAPPA COEFFICIENTS AS GENERATED BY THE
% APBS CODE.
% THE .INM FILE WHICH IS THE INPUT FILE OF THIS CODE.

%SECOND STEP:
% YOU MUST CREATE THE .INM INPUT FILE

% The .inm file parsing is strict.
% input must contain the value of these parameters in exactly this order in a column:
% dime   
% glen   
% T
% dielx_str
% diely_str
% dielz_str
% kappa_str
% charge_str
% pot_str
% pqr_str
% name_str

%|--example born.inm file--|
% 65 65 65               % Number of grid points (AS IN APBS CODE)
% 12 12 12              % in Amstrongs (AS IN APBS CODE)
% 298.15                    % Tempature in Kelvin
% born-dielx.dx       % Filename of input data
% born-diely.dx
% born-dielz.dx
% born-kappa.dx
% born-charge.dx
% born-pot.dx          (solution generated by APBS solver to be compared)
% born-ion.pqr             (pqr file name)
% born_ion_model           (the output filenames will begin with this name)
%|--------------------|

% THIRD STEP:
% YOU MUST CHANGE THE LOCALIZATION OF THE CURRENT DIRECTORY "examples" 
% BY THE PROPER ONE IN THE NEXT LINE

addpath('C:/Users/Marce/Documents/MATLAB/Gradwohl_DFT/Gradwohl_Electrostatic_Solver/examples')

% FORTH STEP:
% YOU MUST CHANGE THE .INM INPUT FILE IN THE ARGUMENT OF THE 'read_inm" FUNCTION IN THE 
% NEXT LINE OF THIS CODE BY THE ONE YOU HAVE PREVIOUSLY CREATED.
% AS AN EXAMPLE, WE USED born.inm AS THE INPUT FILE. 

% YOU ARE DONE. NOW YOU ARE READ TO USE THIS CODE!!!!!! THANKS !!!!

% CALLED MATLAB FILES: 
% read_inm.m (read the input file)
% data_parse.m (read dx files and convert them to data arrays)
% BoundaryCondition.m (evaluate the dirichlet boundary condition along the
% 6 faces)
% BuildA.m (construction of A matrix and b columm vector)
% dx_export.m (convert data arrays to dx format)

%% Part 1.  Read the data

% read the .inm file and display it in the matlab cmd

 [dime, glen, T, dielx_str, diely_str, dielz_str, kappa_str, charge_str, pot_str,pqr_str,nam_str] = read_inm('born.inm');
% [dime, glen, bcfl, T, I_S, dielx_str, diely_str, dielz_str, kappa_str, charge_str, pot_str,pqr_str,nam_str] = read_inm(inputfile)

% read the .dx files

charge=data_parse(charge_str, dime); % data_parse loads the file, and displays the reading ... message
dielx=data_parse(dielx_str, dime);
diely=data_parse(diely_str, dime);
dielz=data_parse(dielz_str, dime);
kappa=data_parse(kappa_str, dime);
APBS_pot_solution=data_parse(pot_str, dime); 

disp('Done!....')

% find the spatial step sizes in each dimension h

for dimension=1:3
  h(dimension)=glen(dimension)/(dime(dimension)-1);  
end


%% Part 2.  solve A*pot=b

% Evaluation of Boundary Conditions
tic

run BoundaryCondition

% Prepare the Laplacian operator A and b

run BuildA

% Solve A*pot=b using the biconjugate gradients stabilized method

disp('LU decomposition....')

tolerance=0.25;
[L U]=luinc(A,tolerance);

disp('Done!....')

disp('Biconjugated gradient method stabilized by LU matrices')
disp('is used to solve the linear equation system ')

accuracy=10^-6;
max_iteration=800;
[pote,flag,relres,iter]=bicgstab(A,bb,accuracy, max_iteration,L,U);

disp('Done!....')

flag
relres
iter

% Add Boundary to Solution

potc=zeros(dime(1)-2,dime(2)-2,dime(3)-2);

for i=2:dime(1)-1
    for j=2:dime(2)-1
        for k=2:dime(3)-1
             pe=(k-2)*(dime(1)-2)*(dime(2)-2)+(j-2)*(dime(1)-2)+i-1;
             potc(i,j,k)=pote(pe);
        end
    end
end

MATLAB_pot=potB;

MATLAB_pot(2:dime(1)-1,2:dime(1)-1,2:dime(1)-1)=potc(2:dime(1)-1,2:dime(1)-1,2:dime(1)-1);

computing_time=toc
%% Part 3: Calculating the absolute error between the APBS and MATLAB solutions
diffe=APBS_pot_solution-MATLAB_pot;
%
aberror=zeros(prod(dime),1);
for i=1:dime(1)
    for j=1:dime(2)
        for k=1:dime(3)
             pe=(k-1)*(dime(1))*(dime(2))+(j-1)*(dime(1))+i;
             aberror(pe)=diffe(i,j,k);
        end
    end
end

absolute_error=norm(aberror,2)

average_error=absolute_error/numel(aberror)

% calculating the absoute error at each point on the grid

aberror2=abs(diffe);

%% Part 4: Write out the electrostatic potential in dx format
dxformat=MATLAB_pot;
namefile='POTENTIAL (KT/e)';
outputfile=strcat(nam_str,'_MATLAB_Potential_Solution.dx');
run dx_export
%
dxformat=APBS_pot_solution;
namefile='POTENTIAL (KT/e)';
outputfile=strcat(nam_str,'_APBS_Potential_Solution.dx');
run dx_export

%% Part 5: Generating the surface Plots

disp('generating plots!....')

% surface defined by z=33
n=33;

% plotting the absolute error

name1=strcat(nam_str,'_absolute_error');

plot1=surf(aberror2(:,:,n),'facecolor','interp');
saveas(plot1,name1,'fig');
saveas(plot1,name1,'jpg');

%plotting the electrostatic potential solutions

name2= strcat(nam_str,'_MATLAB_solution');
plot2=surf(MATLAB_pot(:,:,n),'facecolor','interp');
saveas(plot2,name2,'fig');
saveas(plot2,name2,'jpg');

name3=strcat(nam_str,'_APBS_solution');
plot3=surf(APBS_pot_solution(:,:,n),'facecolor','interp');
saveas(plot3,name3,'fig');
saveas(plot3,name3,'jpg');

disp('Done!....')

disp('Thanks for using our PB solver!!!!....')
%end
