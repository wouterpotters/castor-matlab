% This SCRIPT loads data from CASTOR EDC and saves it to MATLAB structs

% 1. define credentials
% THIS IS SUPER SENSITIVE DATA! NEVER SHARE THESE TWO LINES WITH ANYONE.
% If you can, put these data in a seperate folder where only you have access 
% and load the client_id and client_secret from there.
% 
% create secret: 
% 1) go to https://data.castoredc.com
% 2) login
% 3) go to Account Settings
% 4) scroll down (all the way)
% 5) click on 'show client id' and '(re)generate secret'
% 6) copy the two items in the 2 lines below
client_id = 'SOMTHING-LIKE-TH1S-BLAB-LA1236789101';
client_secret = '12abc345627890example';

id_secret = textread('H:\Scripts\ca_id_secret','%s'); %#ok<DTXTRD>
client_id = id_secret{1}; client_secret = id_secret{2};

% create connection to castor
% this creates a instance c of class castor. This can then be used to
% request data from Castor. Do not save and/or share with others
c = castor(client_id,client_secret);

% get study
my_study_name = 'YOUR STUDY NAME'; % this exact text has to be part of your studyname.
studies = c.request('study'); % get all studies
study = studies(contains({studies.name},my_study_name)); % select requested study

% get list of records / participants
records = c.requestAll('record',study); % get all records; requestAll loops over ALL pages, so be carefull what you ask for with large datasets.

% select only the non-archived records in these id's
records = records(~[records.archived]);

% get variable names for all fields in your study
fields = c.requestAll('field',study);

% find a field with a specific variable_name
field_finder_variable_name = @(input_name) (cellfun(@(f) (contains([f ' '],input_name)),{fields.field_variable_name}));
subject_sex = fields(field_finder_variable_name('sex')); % find the field belonging to variable 'subject_sex'

% loop over all participants to fetch the fieldname sex
for irec = records % loop over all records
    % fetch field
    sex = c.request('study-data-point',study, irec, subject_sex); % get the variable value
    
    % display result
    fprintf('Patient %s: sex# %s\n',irec.record_id,sex);
end

% what does the number 'sex' mean?
% subject_sex.option_group.options.value: 1, 2
% subject_sex.option_group.options.name: male, female (can be different for your study!)
