%clear
%clc

%% This is a testing code for our MATLAB PB solver

% It basically evaluates the residual AND absolute
% error between both the APBS and MATLAB electrostatic potential solutions. 
% FOR VISUAL PORPUSE, IT ALSO GENERATES THE CORRESPONDING TWO PLOTS, ONE  
% TO THE ABSOLUTE ERROR BETWEEN APBS AND MATLAB SOLUTIONS, AND THE OTHER
% FOR THE APBS AND THE MATLAB SOLUTION FOR THE ELECTROSTATIC POTENTIAL.
% IT ALSO write out THE ABSOLUTE ERROR DX FILE. 

% WARNING!!!!!!!!!!!!!!! BEFORE USING IT: 

% PLEASE, ADD THE PATH OF THE CORRESPONDING DX FILES FOR THE ELECTROSTATIC 
% POTNETIAL SOLTIONS TO THE MATLAB SEARCH PATH
% AS IT IS DONE IN THE EXAMPLE PROVIDED IN THE NEXT TWO LINES 

  %MYPATH=handles.cinapbs;
  %MYPATH2=handles.cinmapbs;
  
% COMMENT: NO MORE THAN THESE TWO DX FILES MUST BE IN SUCH DIRECTORY.

% YOU ARE DONE. NOW YOU ARE READY TO USE THIS CODE!!!!!! THANKS !!!!

% CALLED MATLAB FILES: 
% data_parse.m (read dx files and convert them to data arrays)
% dx_export.m (convert data arrays to dx format)
% gridinf.m (read number of grid points, center of the grid and mesh size
% from input file)
diary ('MATLAB_screen.io')
disp('Welcome!!!!!!....')
disp(' ')
disp('This code will calculate the absolute and relative errors between the')
disp('MATLAB and APBS solutions of the PB equation....')
disp(' ')



%% Part 1.  Read the data

disp('Reading the input files....')

% getting grid information

dime=handles.dime;
rmin=handles.rmin;
h=handles.h;

% reading electrostatic potential reference state generated by APBS
if strcmp(handles.apbsreference, '')==0
APBS_pot_ref=data_parse(handles.apbsreference,dime); 
else
 APBS_pot_ref=zeros(dime(1),dime(2),dime(3));
end
% reading electrostatic potential solvated state generated by APBS
if strcmp(handles.apbssolvated, '')==0
APBS_pot_solv=data_parse(handles.apbssolvated,dime); 
else
 APBS_pot_solv=zeros(dime(1),dime(2),dime(3));
end
% reading electrostatic potential reference state generated by MATLAB solver
if strcmp(handles.mapbsreference, '')==0
MATLAB_pot_ref=data_parse(handles.mapbsreference,dime);
else
 MATLAB_pot_ref=zeros(dime(1),dime(2),dime(3));
end
% reading electrostatic potential solvated state generated by MATLAB solver
if strcmp(handles.mapbssolvated, '')==0
MATLAB_pot_solv=data_parse(handles.mapbssolvated,dime); 
else
 MATLAB_pot_solv=zeros(dime(1),dime(2),dime(3));
end


% Defining the reaction filed electostatic potential
MATLAB_pot=MATLAB_pot_solv-MATLAB_pot_ref;
APBS_pot=APBS_pot_solv-APBS_pot_ref;
disp('Done!....')


%% Part 3: Calculating the absolute error between the APBS and MATLAB solutions
diffe2=(APBS_pot-MATLAB_pot)./MATLAB_pot;
diffe=(APBS_pot-MATLAB_pot);
%
[me,ne,pe] = size(MATLAB_pot);
if me~=dime(1)||ne~=dime(2)||pe~=dime(3)
    disp('mismatching dimensions')
    return
end
[me,ne,pe] = size(APBS_pot);
if me~=dime(1)||ne~=dime(2)||pe~=dime(3)
    disp('mismatching dimensions')
    return
end
aberror=zeros(prod(dime),1);
relerror=zeros(prod(dime),1);
for i=1:dime(1)
    for j=1:dime(2)
        for k=1:dime(3)
             pe=(k-1)*(dime(1))*(dime(2))+(j-1)*(dime(1))+i;
             aberror(pe)=diffe(i,j,k);
             relerror(pe)=diffe2(i,j,k);
        end
    end
end
% evaluating the absolute error along all the points on the grid
absolute_error=norm(aberror,2)

% evaluating the average absolute error as the rate between the abosulte error 
%along all the points on the grid and the total number of grid points
average_absolute_error=absolute_error/numel(aberror)

% evaluating the relative error along all the points on the grid
relative_error=norm(relerror,2)

% evaluating the average relative error as the rate between the relative error 
%along all the points on the grid and the total number of grid points
average_relative_error=relative_error/numel(relerror)

% calculating the absolute error at each point on the grid
relerror2=abs(diffe2);
aberror2=abs(diffe);

dirname='COMPARATIVE_ANALYSIS';
mkdir(handles.cout,dirname)

% checking if the user is working on a pc o unix platarform
kt = strfind(handles.cout, '/');
if numel(kt)>0 
    outpath=strcat(handles.cout,'/',dirname);
else
    outpath=strcat(handles.cout,'\',dirname);
end


%% Part 4: Write out the absolute error in dx format
dxformat=aberror2;
namefile='Absolute Error between MATLAB and APBS solutions';
outputfile=strcat(namefile,'.dx');
run dx_export
movefile (outputfile,outpath)
%

dxformat=relerror2;
namefile='relative Error between MATLAB and APBS solutions';
outputfile=strcat(namefile,'.dx');
run dx_export
movefile (outputfile,outpath)
%
%% Part 5: Generating the surface Plots

disp('generating plots!....')

% potential surface
n=(dime(3)+1)/2;

% plotting the absolute error
name1='absolute_error';
plot1=surf(aberror2(:,:,n),'facecolor','interp');
saveas(plot1,name1,'fig');
movefile (strcat(name1,'.fig'),outpath)
saveas(gcf,strcat(name1,'.tiff'),'tiffn');
movefile (strcat(name1,'.tiff'),outpath)

% plotting the relative error
name3='relative_error';
plot1=surf(relerror2(:,:,n),'facecolor','interp');
saveas(plot1,name3,'fig');
movefile (strcat(name3,'.fig'),outpath)
saveas(gcf,strcat(name3,'.tiff'),'tiffn');
movefile (strcat(name3,'.tiff'),outpath)

figure

%plotting the electrostatic potential solutions
name2= strcat('matlab_pot','_and_','apbs_pot');
subplot(1,2,1)
surf(MATLAB_pot(:,:,n),'facecolor','interp');
subplot(1,2,2)
surf(APBS_pot(:,:,n),'facecolor','interp');
saveas(gcf,strcat(name2,'.fig'))
movefile (strcat(name2,'.fig'),outpath)
saveas(gcf,strcat(name2,'.tiff'),'tiffn');
movefile (strcat(name2,'.tiff'),outpath)

disp('Done!....')

disp('Thanks for using our code!!!!....')
%end
diary off
movefile ('MATLAB_screen.io', outpath)
clear