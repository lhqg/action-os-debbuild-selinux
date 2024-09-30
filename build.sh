#!/bin/bash

RC=0

WORKDIR=/source
LOCKFILE=${WORKDIR}/.lock

BUILDROOT="${WORKDIR}/${INPUT_BUILDROOT}"
OUTPUT_DIR="${WORKDIR}/build/${INPUT_OUTPUT_DIR}"
PACKAGE_VERSION="${INPUT_PKG_VERSION}"
GPG_KEY_NAME="${INPUT_SIGNING_KEY_NAME}"
GPG_KEY_ID="${INPUT_SIGNING_KEY_ID}"
GPG_KEY_FILE="${INPUT_SIGNING_KEY_FILE}"

if [ -f ${LOCKFILE} ]
then
  count=0
  waittime=20
  while [ $count -lt 10 -a -f $LOCKFILE ]
  do
    echo "::notice title=DEBbuild::Lock file found, waiting ${waittime}s"
    sleep $waittime
    count=$((count + 1))
  done
  if [ -f ${LOCKFILE}]
  then
    echo "::error title=DEBbuild::Lock still present, aborting."
    exit 127
  fi
fi

touch $LOCKFILE

pwd

[ -d ${OUTPUT_DIR} ] || mkdir -m 0755 -p ${OUTPUT_DIR}

if [ -n "${BUILDROOT}" -a -d "${BUILDROOT}" ]
then
  echo "Build root directory is : ${BUILDROOT}"
  echo "::notice title=DEBbuild::Build root directory is : ${BUILDROOT}"

  # Check that at least one CONTROL file exists
  ls ${BUILDROOT}/*/debian/control > /dev/null 2>&1
  RC=$(($RC + $? ))

  old_pwd=$( pwd )
  export GPG_TTY=$(tty)
  export GNUPGHOME=${BUILDROOT}/.gnupg

  if [ $RC -eq 0 ]
  then
    # Preparing to sign DEB packages
    if [ -s ${BUILDROOT}/${GPG_KEY_FILE} -a -s ${BUILDROOT}/.${GPG_KEY_FILE}.passphrase ] 
    then
      mkdir -m 0700 -p ${GNUPGHOME}
      gpg --batch \
        --passphrase-file ${BUILDROOT}/.${GPG_KEY_FILE}.passphrase \
        --import ${BUILDROOT}/${GPG_KEY_FILE}
      rc1=$?
      sign_options=""
      [ $rc1 -ne 0 ] && echo "::error title=DEBbuild::Could not import private key."
      [ $rc1 -eq 0 ] && sign_options="--force-sign"
    fi

    # Loop over all CONTROL files found
    for control in ${BUILDROOT}/*/debian/control
    do
      package_dir=$( dirname $( dirname $control ) )
      package_name=$( basename ${package_dir} )

      echo "::notice title:DEBbuild:Entering ${package_dir}"
      cd ${package_dir}
      dpkg-buildpackage -v${PACKAGE_VERSION} --jobs=1 --build=binary ${sign_options}
      rc2=$?
      RC=$(($RC + $rc2 ))

      if [ $rc2 -eq 0 ]
      then
        echo "::notice title:DEBbuild:Listing package content."
        dpkg-deb -c ${BUILDROOT}/*.deb 

        echo "::notice title:DEBbuild:Moving files to ${OUTPUT_DIR}"
        mv ${BUILDROOT}/*.deb ${OUTPUT_DIR}/
        RC=$(($RC + $? ))

        mv ${BUILDROOT}/*.{changes,dsc} ${OUTPUT_DIR}/
      fi

      cd $old_pwd
    done

    # Rename generated files with Distro name and version
    if [ $RC -eq 0 ]
    then
      cd ${OUTPUT_DIR}
      . /etc/os-release
      find . -type f -a \
        \( -name '*.deb' -o -name '*.changes' -o -name '*.buildinfo' \) \
        -print0 | xargs -0 \
        tar cfj ${OUTPUT_DIR}/${ID}-${VERSION_ID}.tar.bz2
      RC=$(($RC + $? ))
    fi
  else
    echo "::error title=DEBbuild::Could not find any CONTROL file in ${BUILDROOT}/*/debian/ directories"
    RC=2
  fi

  RC=$(( $RC + $rc1 ))
else
  echo "::error title=DEBbuild::Unable to find the root build directory '${BUILDROOT}'."
fi

rm -f $LOCKFILE

exit $RC