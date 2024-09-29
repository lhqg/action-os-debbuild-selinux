#!/bin/bash

DISTRO=$( cut -d : -f 1 <<< "${INPUT_DISTRIBUTION}" )
DISTRO_NAMEVER=$( cut -d : -f 2 <<< "${INPUT_DISTRIBUTION}" )
PLATFORM="${INPUT_PLATFORM}"
BUILDROOT="${INPUT_BUILDROOT}"
OUTPUT_DIR="${INPUT_OUTPUT_DIR}"
GPG_KEY_NAME="${INPUT_GPG_KEY_NAME}"
GPG_KEY_FILE="${INPUT_GPG_KEY_FILE}"
PLATFORM="${INPUT_PLATFORM}"

RC=0

pwd

if [ -n "${BUILDROOT}" -a -d "${BUILDROOT}" ]
then
  echo "Build root directory is : ${BUILDROOT}"
  echo "::notice title=DEBbuild::Build root directory is : ${BUILDROOT}"

  # Check that at least one CONTROL file exists
  ls ${BUILDROOT}/*/debian/control > /dev/null 2>&1
  RC=$(($RC + $? ))

  old_pwd=$( pwd )
  export GPG_TTY=$(tty)

  if [ $RC -eq 0 ]
  then
    # Preparing to sign DEB packages
    if [ -s ${BUILDROOT}/${GPG_KEY_FILE} -a -s ${BUILDROOT}/.${GPG_KEY_FILE}.passphrase ] 
    then
      gpg --batch \
        --passphrase-file ${BUILDROOT}/.${GPG_KEY_FILE}.passphrase \
        --import ${BUILDROOT}/${GPG_KEY_FILE}
      rc1=$?
      [ $rc1 -ne 0 ] && echo "::error title=DEBbuild::Could not import private key."
    fi

    # Loop over all CONTROL files found
    for control in ${BUILDROOT}/*/debian/control
    do
      package_dir=$( dirname $( dirname $control ) )

      echo "::notice title:DEBbuild:Entering ${package_dir}."
      cd ${package_dir}
      debuild
      RC=$(($RC + $? ))

      if [ $RC -eq 0 ]
      then
        mv ${BUILDROOT}/*.{deb,changes} ${OUTPUT_DIR}/
        RC=$(($RC + $? ))
      fi

      cd $old_pwd
    done

    # Rename generated files with Distro name and version
    cd ${OUTPUT_DIR}
    for file in *
      mv ${file} ${file}-${DISTRO}_${DISTRO_NAMEVER}
      RC=$(($RC + $? ))
    do

    done
  else
    echo "::error title=DEBbuild::Could not find any CONTROL file in ${BUILDROOT}/*/debian/ directories"
    RC=2
  fi

  RC=$(( $RC + $rc1 ))
else
  echo "::error title=DEBbuild::Unable to find the root build directory."
fi

exit $RC