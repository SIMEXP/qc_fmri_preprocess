# qc_fmri_preprocess
A quality control report for the preprocessing of resting-state functional magnetic resonance imaging. To install, you need to download the [latest release](https://github.com/SIMEXP/qc_fmri_preprocess/releases) with dependencies (archive ending with `-with-deps.zip`). Uncompress this archive and add the folder to your Matlab or Octave path:
```
addpath(genpath('path_toolbox'))
```

You need to describe the data in a matlab structure:
```
files.anat.subject1 = '/data/file_anat1.nii.gz';
files.func.subject1 = '/data/file_func1.nii.gz'
files.anat.subject2 = '/data/file_anat2.nii.gz';
files.func.subject2 = '/data/file_func2.nii.gz'
files.template = '/data/template_mni.nii.gz';
```
The IDs for the subjects (here `subject1`, `subject2`, etc) are arbitrary but need to conform to matlab's restrictions on field names (in particular, does not start by numbers and does not contain `-`). You can enter as many subjects as needed. Note that it is important to specify the full path of the datasets. If the preprocessed data has been generated with NIAK, it is possible to get the list of files with the following command:
```
files = niak_grab_qc_fmri_preprocess('path_to_preprocess_data');
```
Then you need to specify the output folder (make sure it is currently empty or does not exist, a lot of files will be generated there):
```
opt.folder_out = '/home/toto/data/qc_report/';
```
Finally, you can adjust the number of processors used to run the pipeline:
```
opt.psom.max_queued = 4; % Will use 4 processors
```
Note that you can further configure the execution modes to use high-performance computing infrastructure, see the following [tutorial](http://psom.simexp-lab.org/psom_configuration.html) (simply replace `opt` by `opt.psom` in the tutorial). You are now ready to generate the reports:
```
niak_pipeline_qc_fmri_preprocess(files,opt);
```
Once the pipeline is complete, just open `index.html`, found in the output folder, in your browser and QC away. There is also an empty spreadsheet `qc_report.csv` ready to store comments, see [this example](https://github.com/SIMEXP/glm_connectome/blob/gh-pages/qc_report.csv). 

More options, including how to choose the slices that appear in the report, can be found in the inline documentation:
```
help niak_pipeline_qc_fmri_preprocess
```

The QC report can be uploaded on github to become an [online github page](https://pages.github.com/), see [this example](http://simexp.github.io/glm_connectome/index.html). We will release at some point guidelines for tagging registration as `OK`, `Maybe` or `Fail`, and commenting on various artefacts. The toolbox has only been tested on Linux and Octave, and may break on other OSes or Matlab. Early stages of testing.... feedback welcome!
