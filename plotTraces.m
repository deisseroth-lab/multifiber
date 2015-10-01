% EDIT ONLY THIS %
filename='m4_social_nostim';

load(strcat('E:\Dropbox\MATLAB\DEISSEROTH\mfp_fear\data\20150811\',filename,'_000_signal.mat'));
load(strcat('E:\Dropbox\MATLAB\DEISSEROTH\mfp_fear\data\20150811\',filename,'_000_reference.mat'));

sig_plot=sig(1:end-1,:);
ref_plot=ref(1:end-1,:);

figure(1); subplot(2,1,1);plot(sig_plot(:,1));
subplot(2,1,2); plot(ref_plot(:,1),'r')
title('Dorsal Striatum')
figure(2); subplot(2,1,1);plot(sig_plot(:,2));
subplot(2,1,2); plot(ref_plot(:,2),'r')
title('Thalamus')
figure(3); subplot(2,1,1);plot(sig_plot(:,3));
subplot(2,1,2); plot(ref_plot(:,3),'r')
title('BLA')
figure(4); subplot(2,1,1); plot(sig_plot(:,4));
subplot(2,1,2); plot(ref_plot(:,4),'r')
title('DRN')