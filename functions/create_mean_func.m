create_mean_func()

n_files = size(subj_run_func_files, 1);

strrep(strjoin(cellstr(num2str((1:260)', 'i%d')), '+'), ' ', '')

matlabbatch{1}.spm.util.imcalc.input = subj_run_func_files;
matlabbatch{1}.spm.util.imcalc.output = out_file;
matlabbatch{1}.spm.util.imcalc.outdir = out_dir;
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2)/2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

