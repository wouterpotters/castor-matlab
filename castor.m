classdef castor
    %CASTOR is a handle class to connect to Castor API. Only
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (Access=private)
        client_id = ''; % default empty
        client_secret = ''; % default empty
        
        % default settings
        base_url = 'https://data.castoredc.com';
        oauth2_address = '/oauth/token'
        sessionoptions = weboptions()
        supported_requests = {'country',...
            'data-point-collection',...
            'field',...
            'field-dependency',...
            'field-optiongroup',...
            'field-validation',...
            'institute',...
            'metadata',...
            'metadatatype',...
            'phase',...
            'query',...
            'record',...
            'report',...
            'report-instance',...
            'report-data-entry',...
            'report-step',...
            'step',...
            'study',...
            'study-data-entry',...
            'survey',...
            'survey-data-entry',...
            'survey-step',...
            'user',...
            'study-data-point'... subtype of study-data-entry
            };
    end
    
    methods
        function obj = castor(varargin)
            %CASTOR connect to castor API to fetch information
            %
            % USAGE:
            % castor_instance = castor(client_id,client_secret) % connect to api
            narginchk(0,2); % always use 2 input arguments
            if nargin == 2
                obj.client_id = varargin{1};
                obj.client_secret = varargin{2};
            else
                clc
                warning('using default values for id & secret')
            end
            obj = obj.connect(); % connect to api and store token.
        end
        function result = requestAll(obj,type,varargin)
            % see also HELP REQUEST for help
            % this function automatically loads all available pages.
            if ~ismember(type,obj.supported_requests)
                error('request type ''%s'' is not supported',type)
            end
            
            % check if input arguments are valid (=char or struct)
            if ~all(cellfun(@(c) ischar(c) | isstruct(c),varargin))
                wrong = varargin(~(cellfun(@(c) ischar(c) | isstruct(c),varargin)));
                locat = find(~(cellfun(@(c) ischar(c) | isstruct(c),varargin)));
                if length(locat) == 1
                    error('request requires only ''char'' or ''struct'' as additional inputs, invalid entry type: ''%s'' at position %i',class(wrong{1}),locat)
                else
                    locat = num2cell(locat);
                    error(['request requires only ''char'' or ''struct'' as additional inputs, invalid entry type at positions ' repmat('%i, ',1,length(locat)) '\b\b'],locat{:})
                end
            end
            
            % convert type - to _
            type = strrep(type,'-','_');
            
            % perform request
            try
                request = eval(['request_' type '(varargin{:})']);
            catch err
                warning('error during request type ''%s''',['request_' type '(varargin{:})']);
                rethrow(err)
            end
            try % try getting result
                result_raw = webread([obj.base_url '/api' request],obj.sessionoptions);
            catch err % catch errors
                switch err.identifier
                    case 'MATLAB:webservices:HTTP404StatusCodeError'
                        warning(err.identifier,'404 NOT FOUND: %s',err.message);
                        result = '';
                        return
                    otherwise
                        rethrow(err)
                end
            end    
            
            while result_raw.page_count > result_raw.page
                result_raw_new = webread(result_raw.x_links.next.href,obj.sessionoptions);
                result_raw.x_links = result_raw_new.x_links;
                result_raw.page_size = result_raw.page_size + result_raw_new.page_size;
                result_raw.page = result_raw_new.page;
                field = fieldnames(result_raw.x_embedded);
                for ifield = field
                    result_raw.x_embedded.(ifield{1}) = [result_raw.x_embedded.(ifield{1}); result_raw_new.x_embedded.(ifield{1})];
                end
            end
            result = parse_result(type,result_raw);
        end
            
        function [result,result_raw] = request(obj,type,varargin)
            % REQUEST(castor,type,...)
            % see also: https://data.castoredc.com/api#/
            %
            % TYPE s allowed: 
            % 'country',
            % 'data-point-collection',
            % 'field',
            % 'field-dependency',
            % 'field-optiongroup',
            % 'field-validation',
            % 'institute',
            % 'metadata',
            % 'metadatatype',
            % 'phase',
            % 'query',
            % 'record',
            % 'report',
            % 'report-instance',
            % 'report-data-entry',
            % 'report-step',
            % 'step',
            % 'study',
            % 'study-data-entry',
            % 'survey',
            % 'survey-data-entry',
            % 'survey-step',
            % 'user'
            % 'study-data-point' (/study/{study_id}/record/{record_id}/study-data-point/{field_id})
            
            % check if request type is valid (compare with list in
            % supported_requests)
            if ~ismember(type,obj.supported_requests)
                error('request type ''%s'' is not supported',type)
            end
            
            % check if input arguments are valid (=char or struct)
            if ~all(cellfun(@(c) ischar(c) | isstruct(c),varargin))
                wrong = varargin(~(cellfun(@(c) ischar(c) | isstruct(c),varargin)));
                locat = find(~(cellfun(@(c) ischar(c) | isstruct(c),varargin)));
                if length(locat) == 1
                    error('request requires only ''char'' or ''struct'' as additional inputs, invalid entry type: ''%s'' at position %i',class(wrong{1}),locat)
                else
                    locat = num2cell(locat);
                    error(['request requires only ''char'' or ''struct'' as additional inputs, invalid entry type at positions ' repmat('%i, ',1,length(locat)) '\b\b'],locat{:})
                end
            end
            
            % convert type - to _
            type = strrep(type,'-','_');
            
            % perform request
            try
                request = eval(['request_' type '(varargin{:})']);
            catch err
                warning('error during request type ''%s''',['request_' type '(varargin{:})']);
                rethrow(err)
            end
            
            try % try getting result
                result_raw = webread([obj.base_url '/api' request],obj.sessionoptions);
            catch err % catch errors
                switch err.identifier
                    case 'MATLAB:webservices:HTTP404StatusCodeError'
                        warning(err.identifier,'404 NOT FOUND: %s',err.message);
                        result = '';
                        return
                    otherwise
                        rethrow(err)
                end
            end
            
            % parse raw result
            result = parse_result(type,result_raw);
        end
        
        function disp(obj)
            builtin('disp',obj);
        end
    end
    
    methods (Access=private)
        function obj = connect(obj)
            %CONNECT(castor) connect to database using existing client_id
            %and client_secret
            
            % define url for oauth2
            url = [obj.base_url obj.oauth2_address];
            
            % get access token
            data = [ 'client_id=', obj.client_id,...
                     '&client_secret=', obj.client_secret,...
                     '&grant_type=client_credentials'];
            try
                 response = webwrite(url,data);
            catch err
                error('Connecting to CASTOR failed. Make sure that you provide a valid client_id and client_secret! \n\nUSAGE: castor_instance = castor(client_id,client_secret). \n\n[error message: %s]',err.message)
            end
            access_token = response.access_token;
            
            % save access token for future calls
            headerFields = {'Authorization', ['Bearer ', access_token]};
            obj.sessionoptions = weboptions('HeaderFields', headerFields, 'ContentType','json');
        end
    end
end

function result = parse_result(type,result_raw)
if isfield(result_raw,'x_embedded') && ~isfield(result_raw.x_embedded,type)
    options = fieldnames(result_raw.x_embedded);
    valid = contains(cellfun(@(x) lower(x),options,'uniformoutput',false),strsplit(lower(type),{'_'}));
    if sum(valid) == 1
        type = options{valid};
    end
end
if isfield(result_raw,'page_count')
    if result_raw.total_items ~= length(result_raw.x_embedded.(type))
        warning('multiple pages of data not supported (yet), only showing page 1.');
    end
end
switch type
    case {'user','study','country','institutes','fields','metadatas','records','fieldOptionGroups'}
        if isfield(result_raw,'x_embedded')
            result = result_raw.x_embedded.(type).'; % transpose to make it an horizontal array with 1 row, multiple columns
        elseif isfield(result_raw,'results')
            result = result_raw.results;
        else
            result = result_raw;
        end
    case 'study_data_point'
        % data with values
        result = result_raw.value;
    otherwise
        warning('parsing not enabled for type ''%s'', using raw data',type);
        result = result_raw;
end
end

function id = struct2id(value,varargin)
% id = STRUCT2ID(value,[type])
% fetch first id from struct result
if nargin == 2
    type = [varargin{1} '_id'];
else
    type = '.*_id';
end
if isstruct(value)
    if length(value) ~= 1
        error('expected 1 institute for request_institute')
    end
    fnames = fieldnames(value);
    select = cellfun(@(f) ~isempty(regexpi(f,type,'once')),fnames);
    if sum(select) == 0
        disp(fnames)
        error('struct2id: no ID found')
    end
    id = value.(fnames{find(select,1)});
elseif ischar(value)
    id = value;
else
    error('expected value to be struct or char')
end
end

function request = request_study(varargin) %#ok<*DEFNU>
% REQUEST = request_study(obj,varargin)
narginchk(0,1);
switch nargin
    case 0 % no inputs
        request = '/study';
    case 1 % 1 input, user ID
        study = varargin{1};
        if isstruct(study)
            if length(study) ~= 1
                error('expected 1 study for request_institute')
            end
            study = study.study_id;
        end
        request = sprintf('/study/%s',study);
    otherwise
        error('type study expects no or StudyID as input')
end
end

function request = request_user(varargin)
% REQUEST = request_user(varargin)
narginchk(0,1);
switch nargin
    case 0
        request = '/user';
    case 1
        request = sprintf('/user/%s',struct2id(varargin{1},'user'));
    otherwise
        error('type user expects no or UserStruct/ID as input')
end
end

function request = request_country(varargin)
% REQUEST = request_country(varargin)
narginchk(0,1);
switch nargin
    case 0
        request = '/country';
    case 1
        request = sprintf('/country/%s',struct2id(varargin{1},'country'));
    otherwise
        error('type country expects no or CountryStruct/ID as input')
end
end

function request = request_institute(study,varargin)
% REQUEST = request_institute(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/institute',struct2id(study,'study'));
    case 2
        institute = varargin{1};
        request =  sprintf('/study/%s/institute/%s',struct2id(study,'study'),struct2id(institute,'institute'));
    otherwise
        error('type study expects StudyStruct/ID and (optionally) instituteStruct/ID as input')
end
end

function request = request_field(study,varargin)
% REQUEST = request_field(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/field?include=metadata|validations|optiongroup',struct2id(study,'study'));
    case 2
        field = varargin{1};
        request =  sprintf('/study/%s/field/%s?include=metadata|validations|optiongroup',struct2id(study,'study'),struct2id(field,'field'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) field Struct/ID as input')
end
end

function request = request_surveypackageinstance(study,varargin)
% REQUEST = request_surveypackageinstance(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/surveypackageinstance',struct2id(study,'study'));
    case 2
        surveypackageinstance = varargin{1};
        request =  sprintf('/study/%s/surveypackageinstance/%s',struct2id(study,'study'),struct2id(surveypackageinstance,'surveypackageinstance'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) surveypackageinstance Struct/ID as input')
end
end

function request = request_field_dependency(study,varargin)
% REQUEST = request_field-dependency(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/field-dependency',struct2id(study,'study'));
    case 2
         field_dependency = varargin{1};
        request =  sprintf('/study/%s/field-dependency/%s',struct2id(study,'study'),struct2id(field_dependency,'field-dependency'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) field-dependency Struct/ID as input')
end
end

function request = request_field_optiongroup(study,varargin)
% REQUEST = request_field-optiongroup(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/field-optiongroup',struct2id(study,'study'));
    case 2
        field_optiongroup = varargin{1};
        request = sprintf('/study/%s/field-optiongroup/%s',struct2id(study,'study'),struct2id(field_optiongroup,'field'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) field-optiongroup Struct/ID as input')
end
end

function request = request_field_validation(study,varargin)
% REQUEST = request_field-validation(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/field-validation',struct2id(study,'study'));
    case 2
        field_validation = varargin{1};
        request = sprintf('/study/%s/field-validation/%s',struct2id(study,'study'),struct2id(field_validation,'field-validation'));
    otherwise
        error('type study expects Study Struct/ID and (optionally)  Struct/ID asfield-validation input')
end
end

function request = request_report_instance(study,varargin)
% REQUEST = request_report-instance(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/report-instance',struct2id(study,'study'));
    case 2
        report_instance = varargin{1};
        request =  sprintf('/study/%s/report-instance/%s',struct2id(study,'study'),struct2id(report_instance,'report-instance'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) report-instance Struct/ID as input')
end
end

function request = request_metadata(study,varargin)
% REQUEST = request_metadata(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/metadata',struct2id(study,'study'));
    case 2
         metadata = varargin{1};
        request =  sprintf('/study/%s/metadata/%s',struct2id(study,'study'),struct2id(metadata,'metadata'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) metadata Struct/ID as input')
end
end

function request = request_metadatatype(study,varargin)
% REQUEST = request_metadatatype(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/metadatatype',struct2id(study,'study'));
    case 2
        metadatatype = varargin{1};
        request =  sprintf('/study/%s/metadatatype/%s',struct2id(study,'study'),struct2id(metadatatype,'metadatatype'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) metadatatype Struct/ID as input')
end
end

function request = request_phase(study,varargin)
% REQUEST = request_phase(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/phase',struct2id(study,'study'));
    case 2
        phase = varargin{1};
        request = sprintf('/study/%s/phase/%s',struct2id(study,'study'),struct2idphase(phase,'phase'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) phase Struct/ID as input')
end
end

function request = request_query(study,varargin)
% REQUEST = request_query(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/query',struct2id(study,'study'));
    case 2
        query = varargin{1};
        request = sprintf('/study/%s/query/%s',struct2id(study,'study'),struct2idquery(query,'query'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) query Struct/ID as input')
end
end

function request = request_record(study,varargin)
% REQUEST = request_record(study,varargin)
% only non-archived records are requested
narginchk(1,3);
switch nargin
    case 1
        request =  sprintf('/study/%s/record?archived=0',struct2id(study,'study'));
    case 2
        record = varargin{1};
        request =  sprintf('/study/%s/record/%s?archived=0',struct2id(study,'study'),struct2idrecord(record,'record'));
    case 3
    otherwise
        error('type study expects Study Struct/ID and (optionally) record Struct/ID as input')
end
end

function request = request_report(study,varargin)
% REQUEST = request_report(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/report',struct2id(study,'study'));
    case 2
        report = varargin{1};
        request =  sprintf('/study/%s/report/%s',struct2id(study,'study'),struct2idreport(report,'report'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) report Struct/ID as input')
end
end

function request = request_step(study,varargin)
% REQUEST = request_step(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/step',struct2id(study,'study'));
    case 2
        step = varargin{1};
        request =  sprintf('/study/%s/step/%s',struct2id(study,'study'),struct2id(step,'step'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) step Struct/ID as input')
end
end

function request = request_survey(study,varargin)
% REQUEST = request_survey(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/survey',struct2id(study,'study'));
    case 2
        survey = varargin{1};
        request =  sprintf('/study/%s/survey/%s',struct2id(study,'study'),struct2idsurvey(survey,'survey'));
    otherwise
        error('type study expects Study Struct/ID and (optionally)  Struct/ID as input')
end
end

function request = request_surveypackage(study,varargin)
% REQUEST = request_surveypackage(study,varargin)
narginchk(1,2);
switch nargin
    case 1
        request =  sprintf('/study/%s/surveypackage',struct2id(study,'study'));
    case 2
        surveypackage = varargin{1};
        request =  sprintf('/study/%s/surveypackage/%s',struct2id(study,'study'),struct2id(surveypackage,'surveypackage'));
    otherwise
        error('type study expects Study Struct/ID and (optionally) surveypackage Struct/ID as input')
end
end

function request = request_data_point_collection(study,type)
% REQUEST = request_surveypackage(study,varargin)
narginchk(2,2);
valid_options = {'study','report-instance','survey-instance'};
if ~ischar(type) || ~ismember(type,valid_options)
    error('type [''%s''] invalid',class(type))
end
request =  sprintf('/study/%s/data-point-collection/%s',struct2id(study,'study'),type);
end

function request = request_study_data_point(study,record,field)
% REQUEST = request_surveypackage(study,varargin)
narginchk(3,3);
request =  sprintf('/study/%s/record/%s/study-data-point/%s',struct2id(study,'study'),struct2id(record,'record'),struct2id(field,'field'));
end

%% NOT IMPLEMENTED / TODO: 
% /study/{study_id}/record/{record_id}/data-point-collection/study
% /study/{study_id}/record/{record_id}/data-point-collection/report-instance
% /study/{study_id}/record/{record_id}/data-point-collection/report-instance/{report_instance_id}
% /study/{study_id}/record/{record_id}/data-point-collection/survey-instance
% /study/{study_id}/record/{record_id}/data-point-collection/survey-instance/{survey_instance_id}
% /study/{study_id}/record/{record_id}/data-point-collection/survey-package-instance/{survey_package_instance_id}
% /study/{study_id}/record/{record_id}/report-instance
% /study/{study_id}/record/{record_id}/report-instance
% /study/{study_id}/record/{record_id}/report-instance/{report_instance_id}
% /study/{study_id}/record/{record_id}/data-point/report/{report_instance_id}
% /study/{study_id}/record/{record_id}/data-point/report/{report_instance_id}/{field_id}
% /study/{study_id}/report/{report_id}/report-step
% /study/{study_id}/report/{report_id}/report-step/{report_step_id}
% /study/{study_id}/record/{record_id}/data-point/study
% /study/{study_id}/record/{record_id}/study-data-point/{field_id}
% /study/{study_id}/record/{record_id}/data-point/survey/{survey_instance_id}
% /study/{study_id}/record/{record_id}/data-point/survey/{survey_instance_id}/{field_id}

% /study/{study_id}/data-point-collection/report-instance/{report_instance_id}
% /study/{study_id}/data-point-collection/survey-instance/{survey_instance_id}
% /study/{study_id}/data-point-collection/survey-package-instance/{survey_package_instance_id}

% /study/{study_id}/survey/{survey_id}/survey-step
% /study/{study_id}/survey/{survey_id}/survey-step/{survey_step_id}

