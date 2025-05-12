#!/bin/sh

print_help() {
    echo "Usage: $0 <working_directory>"
    echo ""
    echo "Parameters:"
    echo "  working_directory   The directory where 'temp' and 'dist' will be created"
    echo ""
    echo "Description:"
    echo "  This script clones the nftables repository, fetches all tags, and creates"
    echo "  a .tar.gz source code package from the python sources inside /nftables/py"
    echo "  for each tag. Packages are stored in the 'dist' directory."
}

validate_params() {
    if [ "$#" -ne 1 ]; then
        print_help
        exit 1
    fi
}

prepare_directories() {
    local WORKING_DIR="$1"
    local TEMP_DIR="${WORKING_DIR}/temp"
    local DIST_DIR="${WORKING_DIR}/dist"
    mkdir -p "${TEMP_DIR}" "${DIST_DIR}"
}

clone_repository() {
    local TEMP_DIR="$1/temp"
    cd "${TEMP_DIR}" || exit 1
    git clone https://git.netfilter.org/nftables
    cd nftables || exit 1
    git fetch --tags
}

build_package() {
    local TEMP_DIR="$1"
    local DIST_DIR="$2"
    local TAG="$3"
    local VERSION="$(echo "${TAG}" | sed 's/^v//')"
    local PACKAGE_DIR="${TEMP_DIR}/package-${VERSION}"
    local PACKAGE_NAME="nftables-${VERSION}.tar.gz"
    
    echo "building nftables ${TAG}"
    
    mkdir -p "${PACKAGE_DIR}/nftables"
    cp -r py/* "${PACKAGE_DIR}/nftables"
    tar -czf "${DIST_DIR}/${PACKAGE_NAME}" -C "${PACKAGE_DIR}" nftables
    rm -rf "${PACKAGE_DIR}"
}

build_packages() {
    local WORKING_DIR="$1"
    local TEMP_DIR="${WORKING_DIR}/temp"
    local DIST_DIR="${WORKING_DIR}/dist"
    local TAGS="$(git tag)"
    for TAG in ${TAGS}; do
        git checkout "${TAG}"
        if [ ! -f "py/setup.py" ]; then
            echo "version ${TAG} does not have setup.py file, skipping"
        else
            build_package "${TEMP_DIR}" "${DIST_DIR}" "${TAG}"
        fi
    done
}

cleanup() {
    local WORKING_DIR="$1"
    local TEMP_DIR="${WORKING_DIR}/temp"
    rm -rf "${TEMP_DIR}"
}

main() {
    validate_params "$@"
    local WORKING_DIR
    WORKING_DIR="$(realpath "$1")"
    prepare_directories "${WORKING_DIR}"
    clone_repository "${WORKING_DIR}"
    cd "${WORKING_DIR}/temp/nftables" || exit 1
    build_packages "${WORKING_DIR}"
    cleanup "${WORKING_DIR}"
}

main "$@"

