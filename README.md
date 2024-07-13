# DOCUMENTATION FOR KRONEMER ET AL., NEUROSCIENCE OF CONSCIOUSNESS, 2024

The following information details the data sources, analysis scripts, and visualization methods for the results and figures presented in Kronemer et al., Neuroscience of Consciousness, 2024. Full methods and statistical analyses details are written in the Kronemer et al., 2024 Methods and Statistical Analyses sections.

## RAW DATA

1. Participant_Information.xlsx: Summary of participant demographic information.

3. Behavioral files (.txt, .log, .xls): Output behavioral files from the afterimage task that are used in subsequent behavioral analyses. Note that the behavioral files include Afterimage_Matching and Main_Experiment task phases that were not analyzed in Kronemer et al.

4. Vividness of Visual Imagery Questionnaire (VVIQ; .pdf): PDF file with participant responses to the VVIQ (scored manually on a scale of 1-5).

## PROCESSED DATA

1. Participant_Afterimage_Image_VVIQ_Data.xlsx; these data are created after running the behavioral analysis script Afterimage_task_behavioral_analysis_v4.m.

## CODE

1. Behavioral analysis (Afterimage_task_behavioral_analysis_v4.m): analyzes subject behavioral files and creates subject-level figures and matrices of all subject results. The output of these behavioral analyses are stored in Participant_Afterimage_Image_VVIQ_Data.xlsx. 

2. Bootstrapping analysis (Afterimage_vs_VVIQ_bootstrapping_analysis.m): reads data from Participant_Afterimage_Image_VVIQ_Data.xlsx and performs a bootstrap analysis on image and afterimage sharpness, contrast, and duration and creates summary figures used in Figure 3 (see details below).

## FIGURES

## Figure 1
Created with Illustrator (Adobe Inc.). See Kronemer et al., 2024 Methods section for details on stimulus source, parameters, and task phases.

## Figure 2
All figure subplots and statistical analyses were made in Prism (GraphPad Inc.) and edited in Illustrator (Adobe Inc.). See Kronemer et al., 2024 Methods section for details on statistical analysis. Source data found in Participant_Afterimage_Image_VVIQ_Data.xlsx: Figure 2A Afterimage Perecption Rate column; Figure 2B VVIQ Score (sum) column; Figure 2C True Minus Selected Image Sharpness and Afterimage Sharpness columns; Figure 2D True Minus Selected Image Contrast and Afterimage Contrast columns; Figure 2E True Minus Selected Image Duration and Afterimage Duration columns.

## Figure 3
Figure 3A,B,D,E,G, and H subplots and statistical analyses were made in Prism (GraphPad Inc.) and edited in Illustrator (Adobe Inc.). See Kronemer et al., 2024 Methods section for details on statistical analysis. Source data found in Participant_Afterimage_Image_VVIQ_Data.xlsx; Figure 3A and B correlation between VVIQ Score (sum) column and Image Contrast/Afterimage Contrast columns, respectively; Figure 3D and E correlation between VVIQ Score (sum) column and Image Sharpness/Afterimage Sharpness columns, respectively; Figure 3G and H correlation between VVIQ Score (sum) column and Image Duration/Afterimage Duration columns, respectively.

Figure 3C,F, and I were created by running the script Afterimage_vs_VVIQ_bootstrapping_analysis.m and edited in Illustrator (Adobe Inc.).

## Figure 4
Values calculated in Prism (GraphPad Inc.) and images created with Illustrator (Adobe Inc.)
