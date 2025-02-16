function [ matches ] = DNA_Pattern_Match( gene, pattern, err_num )
%DNA_Pattern_Match Match DNA patterns in a given DNA string.
%   The function accepts a string of DNA letters (A, C, G, T), a second
%   string that we want to find within the original string (with ACGT, and
%   X for an empty letter) and a number indicating how many errors we allow
%   in the match. The function returns a vector with 1s where there was a
%   match.

% find the convolution threshold:
n = length(find(pattern == 'A')) + length(find(pattern == 'T')) + ...
    length(find(pattern == 'C')) + length(find(pattern == 'G')) - err_num;

% create the number representation of the gene and pattern:
gene_num = zeros(1, length(gene));
gene_num(gene == 'A') = 1;
gene_num(gene == 'T') = -1;
gene_num(gene == 'C') = 1i;
gene_num(gene == 'G') = -1i;
pattern_num = zeros(1, length(pattern));
pattern_num(pattern == 'A') = 1;
pattern_num(pattern == 'T') = -1;
pattern_num(pattern == 'C') = -1i;
pattern_num(pattern == 'G') = 1i;

% return the vector with 1 in the indexes that pass the threshold:
matches = conv(gene_num, pattern_num, 'same');
matches = real(matches);
matches(matches < n) = 0;
matches(matches >= n) = 1;

%%% TODO - think of a solution for the fact that the multiplication can be
%%% TODO - (-1) and then make the error count wrong (one error necomes two)
end

