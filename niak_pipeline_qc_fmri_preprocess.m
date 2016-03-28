function pipe = niak_pipeline_qc_fmri_preprocess(in,opt)
% Generate anatomical and functional figures to QC coregistration
%
% SYNTAX: PIPE = NIAK_PIPELINE_QC_FMRI_PREPROCESS(IN,OPT)
%
% IN.ANAT.(SUBJECT) (string) the file name of an individual T1 volume (in stereotaxic space).
%   Labels SUBJECT are arbitrary but need to conform to matlab's specifications for 
%   field names. 
% IN.FUNC.(SUBJECT) (string) the file name of an individual functional volume (in stereotaxic space)
%   Labels SUBJECT need to be consistent with IN.ANAT. 
% IN.TEMPLATE   (string) the file name of the template used for registration in stereotaxic space.
% OPT.FOLDER_OUT (string) where to generate the outputs. 
% OPT.COORD       (array N x 3) Coordinates for the figure. The default is:
%                               [-30 , -65 , -15 ; 
%                                  -8 , -25 ,  10 ;  
%                                 30 ,  45 ,  60];    
% OPT.PSOM (structure) options for PSOM. See PSOM_RUN_PIPELINE.
% OPT.FLAG_VERBOSE (boolean, default true) if true, verbose on progress. 
% OPT.FLAG_TEST (boolean, default false) if the flag is true, the pipeline will 
%   be generated but no processing will occur.
%
% Note:
%   This pipeline needs the PSOM library to run. 
%   http://psom.simexp-lab.org/
% 
% Copyright (c) Pierre Bellec
% Centre de recherche de l'Institut universitaire de gériatrie de Montréal, 2016.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : visualization, montage, 3D brain volumes

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Defaults

% Inputs
in = psom_struct_defaults( in , ...
    { 'anat' , 'template' , 'func' }, ...
    { NaN   , NaN          , NaN   });

if ~isstruct(in.anat)
    error('IN.ANAT needs to be a structure');
end

if ~isstruct(in.func)
    error('IN.FUNC needs to be a structure');
end

list_subject = fieldnames(in.anat);
if (length(fieldnames(in.func))~=length(list_subject))||any(~ismember(list_subject,fieldnames(in.func)))
    error('IN.ANAT and IN.FUNC need to have the same field names')
end

% Options 
if nargin < 2
    opt = struct;
end
coord_def =[-30 , -65 , -15 ; 
                      -8 , -25 ,  10 ;  
                     30 ,  45 ,  60];
opt = psom_struct_defaults ( opt , ...
    { 'folder_out' , 'coord'      , 'flag_test' , 'psom'   , 'flag_verbose' }, ...
    { pwd            , coord_def , false         , struct() , true                 });

opt.folder_out = niak_full_path(opt.folder_out);
opt.psom.path_logs = [opt.folder_out 'logs' filesep];

%% Add the generation of summary images for all subjects
pipe = struct;
for ss = 1:length(list_subject)
    subject = list_subject{ss};
    if opt.flag_verbose
        fprintf('Adding job: QC report for subject %s\n',subject);
    end
    inj.anat = in.anat.(subject);
    inj.func = in.func.(subject);
    inj.template = in.template;
    outj.anat = [opt.folder_out subject filesep 'summary_' subject '_anat.jpg'];
    outj.func = [opt.folder_out subject filesep 'summary_' subject '_func.jpg'];
    outj.template = [opt.folder_out subject filesep 'summary_template.jpg'];
    outj.report =  [opt.folder_out subject filesep 'report_coregister_' subject '.html'];
    optj.coord = opt.coord;
    optj.id = subject;
    pipe = psom_add_job(pipe,['report_' subject],'niak_brick_qc_fmri_preprocess',inj,outj,optj);
end

%% Generate file names and links for the wrappers
file_wrap = cell(length(list_subject),1);
list_content = cell(length(list_subject),1);
list_wrap{1} = [opt.folder_out 'index.html'];
list_links = sprintf('<li><a href="index.html">Group summary</a></li>\n');
list_content{1} = 'Group statistics go here....';
for ss = 1:length(list_subject)
    subject = list_subject{ss};
    list_wrap{ss+1} = [opt.folder_out 'wrapper_'  subject '.html'];
    list_links = [list_links sprintf('<li><a href="%s">%s</a></li>\n',['wrapper_'  subject '.html'],subject)];
    list_content{ss+1} = sprintf('<object class="internal" type="text/html" data="%s"></object>\n',[subject filesep 'report_coregister_' subject '.html']);
end

%% Read html template
file_self = which('niak_pipeline_qc_fmri_preprocess');
path_self = fileparts(file_self);
file_html = [path_self filesep 'niak_index_qc_fmri_preprocess.html'];
hf = fopen(file_html,'r');
str_html = fread(hf,Inf,'uint8=>char')';
fclose(hf);

%% Generate the wrappers
if opt.flag_verbose 
    fprintf('Adding jobs to generate wrappers html...\n')
end
for ww = 1:length(list_wrap)
    file_wrap = list_wrap{ww};
    if ww==1
       name_job = 'index_html';
       links_ww = strrep(list_links,'<li><a href="index.html">Group summary</a></li>','<li><a class="active" href="index.html">Group summary</a></li>');
    else
       subject = list_subject{ww-1}; 
       name_job = ['wrapper_' subject];
        links_ww = strrep(list_links,sprintf('<li><a href="%s">%s</a></li>\n',['wrapper_'  subject '.html'],subject),sprintf('<li><a class="active" href="%s">%s</a></li>\n',['wrapper_'  subject '.html'],subject));
    end 
    str_write = strrep(str_html,'$LINKS',links_ww);
    str_write = strrep(str_write,'$CONTENT',list_content{ww});
    pipe.(name_job).files_out = file_wrap;
    pipe.(name_job).opt = str_write;
    pipe.(name_job).command = 'hf = fopen(files_out,''w+''); fprintf(hf,''%s'',opt); fclose(hf);';
end

if ~opt.flag_test
    psom_run_pipeline(pipe,opt.psom);
end