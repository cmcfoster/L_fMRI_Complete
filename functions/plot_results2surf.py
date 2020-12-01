from nilearn import plotting
from nilearn.image import load_img
import os

root_dir = '/raid/data'
task = 'dj'
base_dir = root_dir + '/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/group_analyses/' + task
files = [files for files in os.listdir(base_dir) if ('masked.nii.gz' in files) and (not '._' in files)]
paths = [base_dir + '/' + s for s in files]

for i in range(len(paths)):
    img = load_img(paths[i])
    data = img.get_fdata()
    min_thr = min(abs(data[abs(data) > 0]))
    title = files[i].replace('_masked.nii.gz', '').replace('results_', '')
    view = plotting.view_img_on_surf(img, threshold = min_thr, title = title)
    out_file = base_dir + '/results_images/' + files[i].replace('.nii.gz', '.html')
    view.save_as_html(out_file)

for i in range(len(paths)):
    img = load_img(paths[i])
    data = img.get_fdata()
    min_thr = min(abs(data[abs(data) > 0]))
    title = files[i].replace('_masked.nii.gz', '').replace('results_', '')
    out_file = base_dir + '/results_images/' + files[i].replace('.nii.gz', '.svg')
    plotting.plot_img_on_surf(img,
                              views=['lateral', 'medial'],
                              hemispheres=['left', 'right'],
                              colorbar=True,
                              threshold=min_thr,
                              output_file=out_file,
                              title = title)
