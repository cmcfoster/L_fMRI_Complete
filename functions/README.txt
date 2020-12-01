Functions List and Descriptions:

get_base_path – finds base path based on your OS
	output: basepath

import_raw_data – transfer functional and T1 mprage files (based on subject, wave)

segment_brain – segments brain using SPM12 tpms 

brain_extraction – create brain extracted T1 by masking T1 image with binary

get_first_acq_t1 – search all T1s to find the file path for the earliest (first) acquired T1
	output: mprage
