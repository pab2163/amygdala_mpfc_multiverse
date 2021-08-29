# Make Feat FSF files for Least Squares Separate Models for use in beta series analyses
import os
import glob

# Set this to the directory all of the sub### directories live in

# Set this to the directory where you'll dump all the fsf files
os.system('mkdir fsf')

scanlist = glob.glob('../../data/SB*')

# where datat on haba lives
habaPath = '/rigel/psych/users/pab2163'

# Do this for each scan
for scanPath in list(scanlist):
  
  # Determine stim file paths
  name = scanPath.split('/')[3]

  # make a directory to store the 48 output feat directories
  os.system('mkdir ../../data/%s/model/fear/singleTrialModels'%(name))

  # make subject-specific fsf dir for all 48 fsf files per subject
  subFsfDir = 'fsf/' + name
  os.system('mkdir %s'%(subFsfDir))

  for trialnum in range(1,25,1):
    for emotion in ['Fear', 'Neut']:
      replacements = {'SUBNUM':name, 'EMOTION':emotion, 'TRIALNUM':str(trialnum), '/danl/SB/Investigators/PaulCompileTGNG':habaPath}
      with open('lssTemplate.fsf') as infile: 
        with open("%s/%s_%s_%s.fsf"%(subFsfDir, name, emotion, str(trialnum)), 'w') as outfile:
                for line in infile:
              # to make the following work on more versions of python
                    for src, target in replacements.items():
                        line = line.replace(src, target)
                    outfile.write(line)

  print(name)
