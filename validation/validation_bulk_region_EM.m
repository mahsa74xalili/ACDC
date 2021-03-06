function validation_bulk_region_EM(input_path_L1B_ISD,input_path_L1B_ESA,input_path_L2_ESA,path_comparison_results,varargin)
warning('off','MATLAB:MKDIR:DirectoryExists');
warning('off','MATLAB:DELETE:FileNotFound');
%==========================================================================
%==========================HANDLING input argument=========================
%==========================================================================
if(nargin<4 || nargin>6)
    error('Wrong number of input parameters');   
end
p = inputParser;
p.addParamValue('input_path_L2_STL',{''},@(x)ischar(x));
p.parse(varargin{:});
input_path_L2_STL=char(p.Results.input_path_L2_STL);
clear p;


surface_aligned=0;
retrack_flag=1;

filesBulk.inputPath       =   input_path_L1B_ISD;

mkdir(path_comparison_results);

filesBulk.inputFiles      =   dir(filesBulk.inputPath);
filesBulk.indexaDirs      =   find(([filesBulk.inputFiles.isdir]));
filesBulk.indexFiles      =   find(not([filesBulk.inputFiles.isdir]));
filesBulk.nFiles          =   length(filesBulk.indexFiles);             % number of input files
aux=struct2cell(filesBulk.inputFiles); aux=aux(1,:); %Keep the
filesBulk.indexFilesNC=find(~cellfun(@isempty,strfind(aux,'.nc')));
filesBulk.nFilesNC=length(filesBulk.indexFilesNC);
filesBulk.NCFiles=filesBulk.inputFiles(filesBulk.indexFilesNC);

i_files_valid=1;
for i_file=1:filesBulk.nFilesNC
    filename_L1B_ISD=char(filesBulk.inputFiles(filesBulk.indexFilesNC(i_file)).name);
    data_string=filename_L1B_ISD(17:17+30);
    filename_L1B_ISD=strcat(input_path_L1B_ISD,filename_L1B_ISD);
    
    inputL1BESAFiles   = dir(fullfile(input_path_L1B_ESA,['*' data_string(1:15) '*.DBL']));
    inputL2ESAFiles   = dir(fullfile(input_path_L2_ESA,['*' data_string(1:13) '*.DBL']));
    if isempty(input_path_L2_STL)
        inputL2STLFiles   = 1;
    else
        inputL2STLFiles   = dir(fullfile(input_path_L2_STL,['*' data_string(1:15) '*.nc']));
    end
    
    
    if ~isempty(inputL1BESAFiles) && ~isempty(inputL2ESAFiles) && ~isempty(inputL2STLFiles)
        indexL1BESA   =   not([inputL1BESAFiles.isdir]);
        filename_L1B_ESA=strcat(input_path_L1B_ESA,char(inputL1BESAFiles(indexL1BESA).name));
        disp(char(filesBulk.inputFiles(filesBulk.indexFilesNC(i_file)).name))
        indexL2ESA   =   not([inputL2ESAFiles.isdir]);
        filename_L2_ESA=strcat(input_path_L2_ESA,char(inputL2ESAFiles(indexL2ESA).name));
        if ~isempty(input_path_L2_STL)
            indexL2STL   =   not([inputL2STLFiles.isdir]);
            filename_L2_STL=strcat(input_path_L2_STL,char(inputL2STLFiles(indexL2STL).name));
            [validation_structure(i_files_valid)]=L1B_validation_EM(filename_L1B_ISD,filename_L1B_ESA,filename_L2_ESA,path_comparison_results,surface_aligned,retrack_flag,'filename_L2_STL',filename_L2_STL);
        else
            [validation_structure(i_files_valid)]=L1B_validation_EM(filename_L1B_ISD,filename_L1B_ESA,filename_L2_ESA,path_comparison_results,surface_aligned,retrack_flag);
        end
        
        %filename_L1B_ESA=strcat('CS_LTA__SIR_SAR_1B_',data_string,'_C001.DBL');
        %filename_L1B_ESA=strcat(input_path_L1B_ESA,filename_L1B_ESA);
        %filename_L2_ESA=strcat('CS_LTA__SIR_SAR_2__',data_string,'_C001.DBL');
        %filename_L2_ESA=strcat(input_path_L2_ESA,filename_L2_ESA);
        
        
      
        %load(strcat(path_comparison_results,strrep(char(filesBulk.inputFiles(filesBulk.indexFilesNC(i_file)).name),'.nc','_Evaluation.mat')));
        %validation_structure(i_files_valid)=res;
        %clear res;
        
        GEO(i_files_valid)=validation_structure(i_files_valid).GEO;
        ATT(i_files_valid)=validation_structure(i_files_valid).ATT;
        ALT(i_files_valid)=validation_structure(i_files_valid).ALT;
        SURF(i_files_valid)=validation_structure(i_files_valid).SURF;
        WINDELAY(i_files_valid)=validation_structure(i_files_valid).WINDELAY;
        RETRACKED_RANGE(i_files_valid)=validation_structure(i_files_valid).RETRACKED_RANGE.peak_detector;
        SIGMA0(i_files_valid)=validation_structure(i_files_valid).SIGMA0;
        SSH(i_files_valid)=validation_structure(i_files_valid).SSH;
        WVFMS(i_files_valid)=validation_structure(i_files_valid).WVFMS;
        i_files_valid=i_files_valid+1;
        save(strcat(path_comparison_results,'Bulk_validation_information.mat'),'GEO','ATT','ALT','SURF','WINDELAY','RETRACKED_RANGE','SIGMA0','SSH','WVFMS');
    end
end


%% ----------  Ploting ----------------------------------------------------
%% ---------------------------  SSH ---------------------------------------
%--------------------------------------------------------------------------
%-------------- Inter-comparison retrackers -------------------------------
peak_detector=[SSH(:).peak_detector];
figure;
plot([peak_detector(:).RMSE_error_L1B],'*r');
hold on; plot([peak_detector(:).RMSE_error_L2_nocorr],'ob');
title('RMSE error on SSH')
legend('L1B-ISD vs L1B-ESA (threshold retracker)','L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[m]');
print('-dpng',strcat(path_comparison_results,'RMSE_SSH_ESA_ISD.png'))

figure;
plot([peak_detector(:).mean_error_L1B],'*r');
hold on; plot([peak_detector(:).mean_error_L2_nocorr],'ob');
title('Mean error on SSH')
legend('L1B-ISD vs L1B-ESA (threshold retracker)','L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[m]');
print('-dpng',strcat(path_comparison_results,'Mean_error_SSH_ESA_ISD.png'))

%-------------- Fitting ---------------------------------------------------
ISD_peak_retracker=[peak_detector(:).ISD];
ESA_peak_retracker=[peak_detector(:).ESA];
ESA_retracker=[SSH(:).ESA_L2];
figure;
plot([ISD_peak_retracker(:).rmse_fitting],'ob');
hold on; plot([ESA_peak_retracker(:).rmse_fitting],'-m');
plot([ESA_retracker(:).rmse_fitting],'^r');
title('RMSE error on fitted SSH')
legend('L1B-ISD (threshold retracker)','L1B-ESA (threshold retracker)', 'L2-ESA')
xlabel('Track'); ylabel('[m]');
print('-dpng',strcat(path_comparison_results,'RMSE_fitted_SSH.png'))

figure;
plot([ISD_peak_retracker(:).mean_error_fitting],'ob');
hold on; plot([ESA_peak_retracker(:).mean_error_fitting],'-m');
plot([ESA_retracker(:).mean_error_fitting],'^r');
title('Mean error on fitted SSH')
legend('L1B-ISD (threshold retracker)','L1B-ESA (threshold retracker)', 'L2-ESA')
xlabel('Track'); ylabel('[m]');
print('-dpng',strcat(path_comparison_results,'Mean_error_fitted_SSH.png'))


%% ---------------------------  sigma0 ------------------------------------
%--------------------------------------------------------------------------
%-------------- Inter-comparison retrackers -------------------------------
peak_detector=[SIGMA0(:).peak_detector];
figure;
plot([peak_detector(:).RMSE_error_L2],'*r');
title('RMSE error on \sigma^0','Interpreter','Tex')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[dB]');
print('-dpng',strcat(path_comparison_results,'RMSE_sigma0_ESA_ISD.png'))

figure;
plot([peak_detector(:).mean_error_L2],'*r');
title('Mean error on \sigma^0','Interpreter','Tex')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[dB]');
print('-dpng',strcat(path_comparison_results,'Mean_error_sigma0_ESA_ISD.png'))

%-------------- Fitting ---------------------------------------------------
ISD_peak_retracker=[peak_detector(:).ISD];
ESA_retracker=[SIGMA0(:).ESA_L2];
figure;
plot([ISD_peak_retracker(:).rmse_fitting],'ob');
hold on;
plot([ESA_retracker(:).rmse_fitting],'^r');
title('RMSE error on fitted \sigma^0','Interpreter','Tex')
legend('L1B-ISD (threshold retracker)', 'L2-ESA')
xlabel('Track'); ylabel('[dB]');
print('-dpng',strcat(path_comparison_results,'RMSE_fitted_sigma0.png'))

figure;
plot([ISD_peak_retracker(:).mean_error_fitting],'ob');
hold on;
plot([ESA_retracker(:).mean_error_fitting],'^r');
title('Mean error on fitted \sigma^0','Interpreter','Tex')
legend('L1B-ISD (threshold retracker)', 'L2-ESA')
xlabel('Track'); ylabel('[dB]');
print('-dpng',strcat(path_comparison_results,'Mean_error_fitted_sigma0.png'))

%% ---------------------------  Peak power --------------------------------
%--------------------------------------------------------------------------
%-------------- Inter-comparison retrackers -------------------------------
figure;
plot([WVFMS(:).RMSE_error_peak],'*r');
title('RMSE error on peak power')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[dB]');
print('-dpng',strcat(path_comparison_results,'RMSE_peakpower_ESA_ISD.png'))

figure;
plot([WVFMS(:).mean_error_peak],'*r');
title('Mean error on peak power')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[dB]');
print('-dpng',strcat(path_comparison_results,'Mean_error_peakpower_ESA_ISD.png'))

%% ---------------------------  GEOLOCATION -------------------------------
%--------------------------------------------------------------------------
%-------------- Inter-comparison retrackers -------------------------------
GEO_LAT=[GEO(:).LAT];
GEO_LON=[GEO(:).LON];

figure;
plot([GEO(:).mean_error],'*r');
title('RMSE error on latitude (L1B-ESA vs L1B-ISD)')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'Mean_geolocation_error_ESA_ISD.png'))

figure;
plot([GEO_LAT(:).RMSE_error],'*r');
title('RMSE error on latitude (L1B-ESA vs L1B-ISD)')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'RMSE_latitude_ESA_ISD.png'))

figure;
plot([GEO_LAT(:).mean_error],'*r');
title('Mean error on latitude (L1B-ESA vs L1B-ISD)')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'Mean_error_latitude_ESA_ISD.png'))

figure;
plot([GEO_LON(:).RMSE_error],'*r');
title('RMSE error on latitude (L1B-ESA vs L1B-ISD)')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'RMSE_longitude_ESA_ISD.png'))

figure;
plot([GEO_LON(:).mean_error],'*r');
title('Mean error on latitude (L1B-ESA vs L1B-ISD)')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'Mean_error_longitude_ESA_ISD.png'))

%% ---------------------  ATTITUDE INFORMATION ----------------------------
%--------------------------------------------------------------------------
%-------------- Inter-comparison retrackers -------------------------------
ATT_pitch=[ATT(:).pitch];
ATT_roll=[ATT(:).roll];
ATT_yaw=[ATT(:).yaw];
figure;
plot([ATT_pitch(:).RMSE_error],'*r');
title('RMSE error on pitch (L1B-ESA vs L1B-ISD)')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'RMSE_pitch_ESA_ISD.png'))

figure;
plot([ATT_pitch(:).mean_error],'*r');
title('Mean error on latitude (L1B-ESA vs L1B-ISD)')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'Mean_error_pitch_ESA_ISD.png'))

figure;
plot([ATT_roll(:).RMSE_error],'*r');
title('RMSE error on roll (L1B-ESA vs L1B-ISD)')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'RMSE_roll_ESA_ISD.png'))

figure;
plot([ATT_roll(:).mean_error],'*r');
title('Mean error on latitude (L1B-ESA vs L1B-ISD)')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'Mean_error_roll_ESA_ISD.png'))

figure;
plot([ATT_yaw(:).RMSE_error],'*r');
title('RMSE error on roll (L1B-ESA vs L1B-ISD)')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'RMSE_roll_ESA_ISD.png'))

figure;
plot([ATT_yaw(:).mean_error],'*r');
title('Mean error on latitude (L1B-ESA vs L1B-ISD)')
legend('L1B-ISD (threshold retracker) vs L2-ESA')
xlabel('Track'); ylabel('[deg]');
print('-dpng',strcat(path_comparison_results,'Mean_error_roll_ESA_ISD.png'))


