#!/usr/bin/env bash
# shellcheck disable=SC1117

function format_time() {(
    MINS=$(((${2} - ${1}) / 60))
    SECS=$(((${2} - ${1}) % 60))

    if [[ ${MINS} -ge 60 ]]; then
        HOURS=$((MINS / 60))
        MINS=$((MINS % 60))
    fi

    [[ -n ${HOURS} ]] && TIME_STRING="${HOURS}h "
    echo "${TIME_STRING}${MINS}m ${SECS}s"
)}

BLD_ALL_START=$(date +%s)

echo
grep "env:" .travis.yml | grep -v LLVM_VERSION | sed "s/.*env: //g" | while read -r ITEM; do (
    DRIVER_START=$(date +%s)
    read -ra VALUES <<< "${ITEM}"
    for VALUE in "${VALUES[@]}"; do
        export "${VALUE:?}"
    done

    # Make sure that the version suffix is stripped for local builds,
    # where it is assumed that the user will be using a tip of tree build
    [[ -n ${LD} ]] && export LD=${LD//-*}

    echo -e "Running '${ARCH:+ARCH=${ARCH} }${LD:+LD=${LD} }${REPO:+REPO=${REPO} }./driver.sh'... \c"
    if ! ./driver.sh "${@}" &>/dev/null; then
        echo -e "\033[01;31mFailed\033[0m\c"
    else
        echo -e "\033[01;32mSuccessful\033[0m\c"
    fi
    echo " in $(format_time "${DRIVER_START}" "$(date +%s)")"
) done

echo
echo "Total script time: $(format_time "${BLD_ALL_START}" "$(date +%s)")"
echo
