#
# (C) Copyright 2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
#

import datetime
import os
import subprocess


# Error checking
def runprocess(process):

    stdout, stderr = process.communicate()

    # Abort if an error
    if not stderr.decode()=='':
      print("StdOut reported and error: ", stderr)
      exit(1)

    # Return output
    return stdout


# Main function
def main():

    # List of repos to check
    repos = ['fv3-jedi', 'fv3-jedi-lm', 'fv3', 'fms', 'femps']

    # Get starting direcotory
    bundle_dir = os.getcwd()

    # Open file to write information
    now = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%S")
    f = open('git_branches_as_of_'+str(now)+'.txt', "w")

    for repo in repos:

        # Print
        print('Working on: ', repo)
        f.write("\nBranches in "+repo+":\n")

        # Move to repo
        os.chdir(repo)

        # Set and run command to git pull
        PIPE = subprocess.PIPE
        process = subprocess.Popen(['git', 'pull'], stdout=PIPE, stderr=PIPE)
        stdout = runprocess(process)

        # Prune remote branches
        PIPE = subprocess.PIPE
        process = subprocess.Popen(['git', 'remote', 'prune', 'origin'], stdout=PIPE, stderr=PIPE)
        stdout = runprocess(process)

        # Set and run command to get branches
        PIPE = subprocess.PIPE
        process = subprocess.Popen(['git', 'branch', '-a'], stdout=PIPE, stderr=PIPE)
        branches = runprocess(process)

        # Loop over remote branches and get last commit
        for branch in branches.split():

          # Split to get parts of the name
          branch_split = branch.decode().split('/')

          # Only consider remote branches
          if branch_split[0] == 'remotes' and branch_split[-1] != 'HEAD':

            # Get the last commit for the branch
            process = subprocess.Popen(['git', 'log', '--format=\"%H\"', '-n', '1', branch.decode()], stdout=PIPE, stderr=PIPE)
            commit = runprocess(process)

            # Write commit to file
            f.write('Branch: '+branch.decode()+' commit: '+commit.decode())

        # Back to bundle level
        os.chdir(bundle_dir)

    print("\n")

    f.close()

# --------------------------------------------------------------------------------------------------

if __name__ == '__main__':
    main()

# --------------------------------------------------------------------------------------------------
