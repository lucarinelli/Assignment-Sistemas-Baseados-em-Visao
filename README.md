## SBVI objectives:
1) Development of an algorithm for traffic sign detection
2) Development of an algorithm to identify the class of the traffic sign represented in a single-sign image. (different data set)
3) Development of an algorithm that, given a single-sign image of a specific class traffic sign, recognizes the traffic sign shown in the image

### Common grounds:
- edge detection (sobel?)
- gradient direction detection
- region detection (ROI region of interest) - ver trabalho dos búfalos?


### Useful
 - https://www.mathworks.com/matlabcentral/fileexchange/15491-shape-recognition
 - https://www.youtube.com/watch?v=uUQbakpHaRs shape recognition matlab
 - https://www.mathworks.com/help/images/identifying-round-objects.html INDENTIFYING ROUND OBJECTS
 - https://www.youtube.com/watch?v=1-jURfDzP1s image processing made easy

### Dúvidas:
 - há alguma vantagem em usar preto e branco?
 - fazer um top hat para o thresholding dar direito?
 - diferença de binarize RGB e thresholding?
 - lidar com problemas de luminosidade?