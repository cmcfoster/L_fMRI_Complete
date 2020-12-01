# L_fMRI_Complete

fMRI Pipeline for longitudinal study

# 1. Import Raw Data

# 2. Half-Way Space + Group Template

2a. Segment T1s and brain extract

2b. Coregister W1 and W2 T1

2c. Create half-way space of W1 and W2 of their T1s

2d. Create group template of those with half-way space T1s

2e. Resample group template to 3 isotropic and float 32

# 3. fMRI Pre-Processing

3a. Re-align functional volumes within waves

3b. Coregister mean functional volume to wave-specific T1

3c. Move all functional volumes to group space (also stay in MNI space)

3d. Smooth functional images (6mm)

3e. Extract motion estimation (using in-house rather than ArtRepair)

3f. Extract CSF, WM, and GS (and DVARS)

3g. Calculate temporal derivatives and its squared of motion, CSF, WM, and GS

# 4. First/Subject-Level Analysis (Fixed-Effects)

4a. Set QC parameters (behavioral, motion, dietabets, number of runs)

4b. Estimate per SS per waves

4c. Contrasts:

* con001-con004: One for each condition
* con005: Task vs Control
* con006: Linear with Control
* con007: Linear without Control
* con008: Quadratic with Control

# 5. Second/Group-Level Analysis (Mixed-Effects using 3dLME)

Formula: nii ~ age_w1 * difficulty * time_weeks + (1 | subj) + (0 + difficulty | subj)

5a. DJ

5b. n-back

5c. convert results to MNI for coords/viewing

5d. Compare our group template space vs MNI space results
