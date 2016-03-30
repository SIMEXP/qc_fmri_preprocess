# qc_fmri_preprocess
A quality control report for the preprocessing of resting-state functional magnetic resonance imaging. To install, you need to download the [latest release]() with dependencies (archive ending with `-with-deps.zip`. Uncompress this archive and add the folder to your Matlab or Octave path:
```
addpath(genpath('path_toolbox'))
```

You need to describe the data in a matlab structure:
```
files.anat.subject1 = 'file_anat1.nii.gz';
files.func.subject1 = 'file_func1.nii.gz'
files.anat.subject2 = 'file_anat2.nii.gz';
files.func.subject2 = 'file_func2.nii.gz'
files.template = 'template_mni.nii.gz';
```
The IDs for the subjects (here `subject1`, `subject2`, etc) are arbitrary but need to conform to matlab's restrictions on field names (in particular, does not start by numbers and does not contain `-`). You can enter as many subjects as needed. Then you need to specify the output folder:
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

The toolbox has only been tested on Linux and Octave, and may break on other OSes or Matlab. Early stages of testing.... feedback welcome!
