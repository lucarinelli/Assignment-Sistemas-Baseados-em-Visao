# Description
Some MATLAB scripts to work on a subset of the German Traffic Sign Detection Benchmark (GTSDB) and the German Traffic Sign Recognition Benchmark (GTSRB).

These scripts have been developed as an assignment for the course of Sistemas Baseados em Visão (Digital Image Processing) of the Facultade de Engenharia da Universidade do Porto, Portugal.

The assignment is divided in 3 tasks:
1) Task 1: Development of an algorithm for traffic sign detection
2) Task 2: Development of an algorithm to identify the class of the traffic sign represented in a single-sign image (different data set)
3) Task 3: Development of an algorithm that, given a single-sign image of a specific class traffic sign, recognizes the traffic sign shown in the image

A more detailed description of the work done can be found in the report. The presentation used in the last lecture of the course is also available in the repository.

# Abstract from the report
The present  work serves as a set of algorithms for traffic sign detection, classification and recognition given a reasonable image. In these tasks color segmentation is used together with edge detection to construct binary images that are then filtered and analyzed based  on their properties. Lines and circles detection with Hough transform is used to confirm some results. Detection can be calibrated to reach precision over 90% with a recall over 80% on the test cases provided. The classifier reaches 100% precision and recall. Good results  are obtained also with the recognizer.
