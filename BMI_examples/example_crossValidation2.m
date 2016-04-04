clear all;
OpenBMI('C:\Users\Administrator\Desktop\BCI_Toolbox\git_OpenBMI\OpenBMI') % Edit the variable BMI if necessary
global BMI;
BMI.EEG_DIR=['C:\Users\Administrator\Desktop\BCI_Toolbox\git_OpenBMI\DemoData'];

%% DATA LOAD MODULE
file=fullfile(BMI.EEG_DIR, '\calibration_motorimageryVPkg');
marker={'1','left';'2','right';'3','foot';'4','rest'};
[EEG.data, EEG.marker, EEG.info]=Load_EEG(file,{'device','brainVision';'marker', marker;'fs', [100]});

field={'x','t','fs','y_dec','y_logic','y_class','class', 'chan'};
CNT=opt_eegStruct({EEG.data, EEG.marker, EEG.info}, field);
CNT=prep_selectClass(CNT,{'class',{'right', 'left'}});

%% CROSS-VALIDATION MODULE
CV.prep={ % commoly applied to training and test data
    'CNT=prep_filter(CNT, {"frequency", [7 13]})'
    'SMT=prep_segmentation(CNT, {"interval", [750 3500]})'
    };
CV.train={
    '[SMT, CSP_W, CSP_D]=func_csp(SMT,{"nPatterns", [3]})'
    'FT=func_featureExtraction(SMT, {"feature","logvar"})'
    '[CF_PARAM]=func_train(FT,{"classifier","LDA"})'
    };
CV.test={
    'func_projection',{}
    'func_featureExtraction',{'logvar'}
    'classifier_applyClassifier',{}
    };
% CV.perform={
%     'loss=cal_loss(out, label)'
%     }
CV.option={
'KFold','10'
};

[loss]=eval_crossValidation(CNT, CV); % input : eeg, or eeg_epo