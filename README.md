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
The IDs for the subjects (here `subject1`, `subject2`, etc) are arbitrary but need to conform to matlab's restrictions on field names (in particular, does not start by numbers and does not contain `-`). You can enter as many subjects as needed. Note that it is important to specify the full path of the datasets. Then you need to specify the output folder (make sure it is currently empty or does not exist, a lot of files will be generated there):
```
opt.folder_out = '/home/toto/data/qc_report/';
```
Finally, you can adjust the number of processors used to run the pipeline:
```
opt.psom.max_queued = 4; % Will use 4 processors
```
Note that you can further configure the execution modes to use high-performance computing infrastructure, see the following [tutorial](http://psom.simexp-lab.org/psom_configuration.html). You are now ready to generate the reports:
```
niak_pipeline_qc_fmri_preprocess(files,opt);
```
Once the pipeline is complete, just open `index.html`, found in the output folder, in your browser and QC away. There is also an empty spreadsheet `qc_report.csv` ready to receive commments, see [this example](https://github.com/SIMEXP/glm_connectome/blob/gh-pages/qc_report.csv). We will release at some point guidelines for tagging registration as `OK`, `Maybe` or `Fail`. The toolbox has only been tested on Linux and Octave, and may break on other OSes or Matlab. Early stages of testing.... feedback welcome!
