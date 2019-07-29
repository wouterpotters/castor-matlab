# castor-matlab
Matlab class to connect to castor API on https://data.castoredc.com/api#/. First draft, so don't expect miracles. 

## usage
```Matlab
castor_instance = castor(client_id,client_secret) % create instance of castor class -- this connects to the API
castor_instace.request('study') % get all available studies - this fetches data from the API
```

Further tips: see the [example file](example_castor.m)

## features
The following end points are implemented:
- country
- data-point-collection
- field
- field-dependency
- field-optiongroup
- field-validation
- institute
- metadata
- metadatatype
- phase
- query
- record
- report
- report-instance
- report-data-entry
- report-step
- step
- study
- study-data-entry
- survey
- survey-data-entry
- survey-step
- user
- study-data-point (/study/{study_id}/record/{record_id}/study-data-point/{field_id})

## limitations
Currently not all endpoints from the API (as described on ) are implemented. Feel free to add them using a [pull request](https://help.github.com/en/articles/about-pull-requests).
- all PUT commands are _not_ supported 
- the following GET commands are _not_ implemented
    * /study/{study_id}/record/{record_id}/data-point-collection/study
    * /study/{study_id}/record/{record_id}/data-point-collection/report-instance
    * /study/{study_id}/record/{record_id}/data-point-collection/report-instance/{report_instance_id}
    * /study/{study_id}/record/{record_id}/data-point-collection/survey-instance
    * /study/{study_id}/record/{record_id}/data-point-collection/survey-instance/{survey_instance_id}
    * /study/{study_id}/record/{record_id}/data-point-collection/survey-package-instance/{survey_package_instance_id}
    * /study/{study_id}/record/{record_id}/report-instance
    * /study/{study_id}/record/{record_id}/report-instance
    * /study/{study_id}/record/{record_id}/report-instance/{report_instance_id}
    * /study/{study_id}/record/{record_id}/data-point/report/{report_instance_id}
    * /study/{study_id}/record/{record_id}/data-point/report/{report_instance_id}/{field_id}
    * /study/{study_id}/report/{report_id}/report-step
    * /study/{study_id}/report/{report_id}/report-step/{report_step_id}
    * /study/{study_id}/record/{record_id}/data-point/study
    * /study/{study_id}/record/{record_id}/study-data-point/{field_id}
    * /study/{study_id}/record/{record_id}/data-point/survey/{survey_instance_id}
    * /study/{study_id}/record/{record_id}/data-point/survey/{survey_instance_id}/{field_id}
    * /study/{study_id}/data-point-collection/report-instance/{report_instance_id}
    * /study/{study_id}/data-point-collection/survey-instance/{survey_instance_id}
    * /study/{study_id}/data-point-collection/survey-package-instance/{survey_package_instance_id}
    * /study/{study_id}/survey/{survey_id}/survey-step
    * /study/{study_id}/survey/{survey_id}/survey-step/{survey_step_id}
