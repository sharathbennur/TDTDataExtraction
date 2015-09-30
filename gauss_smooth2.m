function [tbin,SDF]=gauss_smooth2(spikes,bin,nTrials,tmin,tmax)

% function to smooth a spiketrain using a gaussian with SD = bin in ms
% Similar to gauss_smooth, only here tmin, tmax & bin-size are all
% specified
% Input:
%   spikes - array containing all spikes from nTrials(number of trials)
%   bin - size of smoothing bin in ms
% Output:
%   tbin: x-axis time
%   SDF: spike density function
% created by BSS - Oct 08
 
nTail = bin*5;
dist=(-nTail:nTail)';
gaus=1/(bin*sqrt(2*pi))*exp(-((dist.^2)/(2*bin^2)));

% create a 1ms timebinned x-axis for what follows
tbin = tmin:1:tmax; tbin=tbin';
PSTH = histc(spikes,tbin)/nTrials*1000;

SDFtemp = conv(PSTH, gaus);
nSDF = size(SDFtemp,1);
% [nSDF,m] = size(SDFtemp);
SDF = SDFtemp(nTail+1:nSDF-nTail);