function C = le (A, B)
%A <= B Less than or equal to.
% C = (A <= B) is an element-by-element comparison of A and B.  One or
% both may be scalars.  Otherwise, A and B must have the same size.
%
% The input matrices may be either GraphBLAS and/or MATLAB matrices, in
% any combination.  C is returned as a GraphBLAS matrix.
%
% See also GrB/lt, GrB/gt, GrB/ge, GrB/ne, GrB/eq.

% The pattern of C depends on the type of inputs:
% A scalar, B scalar:  C is scalar.
% A scalar, B matrix:  C is full if A<=0, otherwise C is a subset of B.
% B scalar, A matrix:  C is full if B>=0, otherwise C is a subset of A.
% A matrix, B matrix:  C is full.

% SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2020, All Rights
% Reserved. http://suitesparse.com.  See GraphBLAS/Doc/License.txt.

if (isobject (A))
    A = A.opaque ;
end

if (isobject (B))
    B = B.opaque ;
end

[am, an] = gbsize (A) ;
[bm, bn] = gbsize (B) ;
a_is_scalar = (am == 1) && (an == 1) ;
b_is_scalar = (bm == 1) && (bn == 1) ;

ctype = gboptype (gbtype (A), gbtype (B)) ;

if (a_is_scalar)
    if (b_is_scalar)
        % both A and B are scalars.  C is full.
        C = GrB (gbemult (gbfull (A, ctype), '<=', gbfull (B, ctype))) ;
    else
        % A is a scalar, B is a matrix
        if (gb_get_scalar (A) <= 0)
            % since a <= 0, entries not present in B result in a true
            % value, so the result is dense.  Expand A to a dense matrix.
            A = gb_scalar_to_full (bm, bn, ctype, A) ;
            B = gbfull (B, ctype) ;
            C = GrB (gbemult (A, '<=', B)) ;
        else
            % since a > 0, entries not present in B result in a false
            % value, so the result is a sparse subset of B.  select all
            % entries in B >= a, then convert to true.
            C = GrB (gbapply ('1.logical', gbselect (B, '>=', A))) ;
        end
    end
else
    if (b_is_scalar)
        % A is a matrix, B is a scalar
        if (gb_get_scalar (B) >= 0)
            % since b >= 0, entries not present in A result in a true
            % value, so the result is dense.  Expand B to a dense matrix.
            B = gb_scalar_to_full (am, an, ctype, B) ;
            A = gbfull (A, ctype) ;
            C = GrB (gbemult (A, '<=', B)) ;
        else
            % since b < 0, entries not present in A result in a false
            % value, so the result is a sparse subset of A.  select all
            % entries in A <= b, then convert to true.
            C = GrB (gbapply ('1.logical', gbselect (A, '<=', B))) ;
        end
    else
        % both A and B are matrices.  C is full.
        C = GrB (gbemult (gbfull (A, ctype), '<=', gbfull (B, ctype))) ;
    end
end

