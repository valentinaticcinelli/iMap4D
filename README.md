# iMap4D
A toolbox for the analysis of Virtual Reality eye-tracking data, with creation of 4D fixation maps and statistical analysis.

For now, only static VR stimuli are compatible with the toolbox: major work will follow to make it suitable to the investigation of time-variable stimuli, which is of course where Virtual Reality experiments make more sense and carry the most potential. 
Therefore, bear with us!

This toolbox is thought as an extension of iMap4, and it preserves the underlying concepts on Linear Mixed Modelling and Non Parametrical Statistical Analysis. An extensive guidebook for iMap4D is still in preparation, however the guide for iMap4 still applies in large measure:  https://junpenglao.gitbooks.io/imap4_guidebook/content/

To start the toolbox's interface, simply run the file iMAP4D.m.

A working simulation can then be run by uploading the following files from the folder 'Data_sample_4D_DEMO'
- 'dataset_teapot.txt' after clicking on 'Import 4D data'
        the file contains the dataset in 13 columns, including Subject ID
- 'label4D.txt' after selecting 'Check 4D Columns'   
        the file contains the Columns name for the dataset file
- 'teapot.obj' after clicking on 'Import 3D Model'
        the file contains the 3D model of the standard Utah teapot, according to Wavefront fromat (.obj)
        

This version is a beta. We did our best in debugging, but please let us now if you run into any issues.         
Also, for questions, suggestions or just to make sure you receive notifications on major updates, please feel free to drop an email to:
v.ticcinelli@unifr.ch

Cheers!
