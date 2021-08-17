# Converting DICOM to NIFTI files


## `1_dicom2nifti.py`

1. Loops through the original SB study structure to find all available DICOM files for all scan runs, then compiles NIFTI images using [dcm2niix](https://github.com/rordenlab/dcm2niix)
2. Places NIFTI BOLD images into a new file structure in the style of Jeanette Mumford's FSL tutorials (not BIDS)
3. **Note:** In the original SB study data structure, not all scan runs had DICOM files labeled in the same way. So, the code makes a couple passes for finding the files of differing label types (i.e. `001` vs `1` in the filename)