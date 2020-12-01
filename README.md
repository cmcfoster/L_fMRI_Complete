# L_fMRI_Complete

fMRI Pipeline for longitudinal study

# 1. Import Raw Data

# 2. Half-Way Space

2a. Segment T1s and brain extract

2b. Coregister W1 and W2 T1

# 3. Group Template

3a. Create half-way space of W1 and W2 of their T1s

3b. Create group template of those with half-way space T1s

3c. Resample group template to 3 isotropic and float 32

# 4. fMRI Pre-Processing

4a. Re-align functional volumes within waves

4b. Coregister mean functional volume to wave-specific T1

4c. Move all functional volumes to group space (also stay in MNI space)

4d. Smooth functional images (6mm)

4e. Extract motion estimation (using in-house rather than ArtRepair)

4f. Extract CSF, WM, and GS (and DVARS)

4g. Calculate temporal derivatives and its squared of motion, CSF, WM, and GS

# 5. First/Subject-Level Analysis (Fixed-Effects)

5a. Set QC parameters (behavioral, motion, dietabets, number of runs)

5b. Estimate per SS per waves

5c. Contrasts:

* con001-con004: One for each condition
* con005: Task vs Control
* con006: Linear with Control
* con007: Linear without Control
* con008: Quadratic with Control

# 6. Second/Group-Level Analysis DJ (Mixed-Effects using 3dLME)

Formula: nii ~ age_w1 * difficulty * time_weeks + (1 + difficulty | subj)

6a. convert results to MNI for coords/viewing

6b. Compare our group template space vs MNI space results

# 7. Second/Group-Level Analysis NBack (Mixed-Effects using 3dLME)

Formula: nii ~ age_w1 * difficulty * time_weeks + (1 + difficulty | subj)

7a. convert results to MNI for coords/viewing

7b. Compare our group template space vs MNI space results
