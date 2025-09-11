#!/bin/bash
 
###############################################################
#
# bin/setupProjectFromTemplate.sh [-p <package_name>] [--package <package_name>]
#                                 [-f <prefix_code>] [--prefix <prefix_code>]
#                                 [-h] [--help]
#
###############################################################
 
performValidationChecks () {
  local has_validation_check_failed=false
 
  # Verify the package name
  if [ -z "${package_name}" ]
    then
      echo "Please provide the package name using the '--package' flag."
      # usage
      # exit 1
      has_validation_check_failed=true
  fi
 
  # Verify the prefix code
  if [ -z "${prefix_code}" ]
    then
      echo "Please provide the prefix code using the '--prefix' flag."
      # usage
      # exit 1
      has_validation_check_failed=true
  fi
 
  if [[ "${has_validation_check_failed}" = true ]]
    then
      usage
      exit 1
  fi
}
 
usage () {
  echo ""
  echo 'Usage: setupProjectFromTemplate.sh [-p <package_name>] [--package <package_name>]'
  echo '                                   [-f <prefix_code>] [--prefix <prefix_code>]'
  echo '                                   [-h] [--help]'
  exit 0
}
 
exit_if_next_arg_is_invalid () {
  [[ -z "$1" ]] && usage
  [[ "$1" =~ ^\- ]] && usage
}
 
package_name=''
prefix_code=''
 
while [[ $# -gt 0 ]]; do
  case "$1" in
    '-p'|'--package')
      shift
      exit_if_next_arg_is_invalid "$1"
      package_name="$1"
      echo "Setting package name to be ${package}"
      shift
      ;;
    '-f'|'--prefix')
      shift
      exit_if_next_arg_is_invalid "$1"
      prefix_code="$1"
      echo "Setting prefix code to be ${prefix}."
      shift
      ;;
    '-h'|'--help')
      usage
      ;;
    *)
      echo "ERROR: Incorrect flag specified '$1'"
      usage
      ;;
  esac
done
 
###############################################################################
#
# MAIN SCRIPT BEGINS HERE
#
###############################################################################
clear
 
performValidationChecks
 
prefix_code_UPPERCASE=$( echo $prefix_code | tr a-z A-Z )
 
if [ -d "sfdx-source/$prefix_code" ]
  then
    rm -r "sfdx-source/$prefix_code"
fi
 
# Changes to make
  # rename files and folders
  mv config/rpbp-enterprise-project-scratch-def.json config/$prefix_code-enterprise-project-scratch-def.json
  mv sfdx-source/rpbp sfdx-source/$prefix_code
 
  # Change all references of rpbp to be the package's prefix
  sed -i "s/rpbp/$prefix_code/g" sfdx-project.json
  sed -i "s/rpbp/$prefix_code/g" bin/resetScratchOrg.sh
  sed -i "s/REF2GP/$prefix_code_UPPERCASE/g" bin/resetScratchOrg.sh
  sed -i "s/rpbp/$prefix_code/g" .gitignore
 
  # Change all references of reference-project-base-package to be the package's name
  sed -i "s/reference-project-base-package/$package_name/g" bin/resetScratchOrg.sh
  sed -i "s/rpbp/$prefix_code/g" bin/resetScratchOrg.sh
  sed -i "s/reference-project-base-package/$package_name/g" config/$prefix_code-enterprise-project-scratch-def.json
  sed -i "s/rpbp/$package_name/g" sfdx-project.json
  
rm -f bin/setupProjectFromTemplate.sh
 
git add .
git commit -m "setup of project $package_name" .
 