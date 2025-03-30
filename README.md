# RAVIR Dataset Challenge

## Overview
This project details the creation of an algorithm designed in MATLAB to efficiently eliminate electrocardiogram (ECG) interference from electromyogram (EMG) signals. Data collection involved the use of Myoware2.0 EMG sensors paired with a Teensy4.1 microcontroller and the WizFi360 wireless module. The process included meticulous skin preparation and sensor placement before recording contaminated EMG data from the Rectus Abdominus. 

The algorithm filtered the data selectively using the wavelet transform. Thresholding windowed segments and a simple voting system helped to remove the ECG while preserving the EMG. Additionally, a basic EMG activation algorithm was used to apply different ECG filtering during relaxation and contraction.   

The algorithm performance was good, but a variety of factors such as a different test subject, different sensor placement, or a different sampling frequency could affect the tuned parameters of the algorithm and thus its ability to remove ECG. In the future, a more diverse data set would be required to generalize the algorithm.  


# Introduction
An electromyogram (EMG) captures the electrical signals generated within muscles when they are contracting. EMG signals are commonly analyzed to evaluate gate, muscle activation levels, muscle interplay, power spectra changes with fatigue, and more. EMG is most commonly recorded on the surface of the skin above the muscle of interest, but can also be performed using a fine wire placed under the skin into the muscle.
    
An essential variable for quantifying the EMG signal is power, often obtained through non-linear wavelet transform methods (https://doi.org/10.1016/j.jelekin.2005.07.004). However, challenges like power line interference, electronic noise, and movement artifacts frequently co-occur during EMG measurements. Advanced techniques such as wavelet analysis or independent component analysis are available to mitigate these unwanted signals (https://doi.org/10.1016/j.jneumeth.2006.06.005 ).
EMG recordings from certain body areas, especially the trunk, are prone to contamination by the electrical activity of the heart muscle (ECG) due to their proximity to the heart. The ECG signal can significantly contribute to EMG signal power, necessitating the suppression or separation of the ECG signal during analysis.

For this project, data was recorded that would purposefully be contaminated with ECG, and then a method of removing ECG from EMG was designed. The new method combined ideas from the previous simple methods to filter more effectively while preserving more of the original signal. The algorithm programmatically found the QRS complexes in the wavelet transform, then the data was filtered using a basic voting system, which helped preserve the original signal.


# Results
The results comprised a comparison between the original and filtered signals. The time domain and wavelet transforms were compared visually. Shown below are one set of results showing the original and filtered time domain and wavelet trasnforms.

Time Domain Signals
![abs1_sig](https://github.com/user-attachments/assets/62697659-8234-4ac5-845c-65613ee82422)

Wavelet Transform
![abs1_cwt](https://github.com/user-attachments/assets/e3e8f2ba-ea38-41b9-a226-d3cf3ce5a9b6)

# Conclusions
The algorithm developed here did a good job of removing the ECG signal from the baseline test, leaving only variations on the same order of magnitude as the 60Hz noise. In the other test, the algorithm performed similarly for QRS complexes that occurred during muscle relaxation. The performance during muscle activation was also fairly good. When EMG activation was detected during muscle contraction, the filtering height changed to preserve the EMG at cost of less ECG filtering.

The algorithm was very good at removing ECG content but had to be carefully tuned to avoid removing excessive amounts of EMG content. The main weakness of the algorithm is that it is not fully adaptable, meaning if data were recorded from a different individual, on a different muscle, or at a different sampling frequency, the algorithm's performance could vary. Further tests with a broader data set are required to generalize the algorithm. 

