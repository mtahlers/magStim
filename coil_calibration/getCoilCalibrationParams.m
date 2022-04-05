function [A,c,Ainv] = getCoilCalibrationParams( U , B , separateOffsetPath )
% [A,c,Ainv] = getCoilCalibrationParams( U , B )
% 
% solves set of linear equations to extract matrix A, transforming voltages to field vectors. 
% Inversion of non-bias components of A is used to compute the necessary control voltages for a desired stimulus
% set of equations: B[3xN] = A * U[3xN] solved for A
%
% inputs:
%   U: N voltage triplets(xyz) [3xN]
%   B: N measured respective field vector triplets(xyz) [3xN]
%
% outputs:
%   A: transformation matrix A, transforming voltages to field vectors. 
%   c: offset of the field
%   Ainv: inverse transformation matrix to get control voltages of a desired stimulus
%   
% (hard-iron) offset can be solved along the same operation or separately if a set of 0V stimuli was applied.
% This option can be toggled with 'separateOffsetPath'. default is true when a 0V triplet is present.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% usage:
% extract parameters:
% [A,c,Ainv] = getCoilCalibrationParams( U , B);
%
% apply parameters to generate control voltages U_stim for a new desired stimulus B_stim:
% U_stim = A\(B_stim-c); 
%   or alternatively:
% U_stim = Ainv*(B_stim-c); 


% assertion of correct input
assert( isequal(size(U),size(B)),'U and B must have the same shape' );
assert( size(U,1)==3,'xyz coordinates must be in dimension 1' );
assert( size(B,1)==3,'xyz coordinates must be in dimension 1' );


%% decision on using a different path for offset
if nargin<3
    % if not specified, look at data to decide
    separateOffsetPath = -1;
end

% check if there is at least one 0V triplet
centerTriplets = all(~U,1);

if (separateOffsetPath==1) && ~any(centerTriplets)
    error('couldnt find 0V triplet though it was requested')
elseif (separateOffsetPath~=0) && any(centerTriplets) 
    separateOffsetPath = 1;
else
    separateOffsetPath = 0;
end

if separateOffsetPath
    % offset is determined when all coils are off
    c = B(:,centerTriplets);
    c = mean(c,2); % take mean of all samples, consider median if you have extreme outliers
    if sum(centerTriplets)<5; warning('using only a few samples to estimate offset'); end
end

%% core

if separateOffsetPath
    B = B-c; % subtract offset
    B = B(:,~centerTriplets); % avoid reusing 0V triplets
    U = U(:,~centerTriplets); % avoid reusing 0V triplets
    A = B/U; % solve equations
else  
    U(4,:) = 1; % add offset term
    A = B/U; % solve equations
    
    % split up matrix
    c = A(:,4);
    A = A(1:3,1:3);
end



if nargout>2
   % optional 3rd output
   Ainv = A^-1; 
end

