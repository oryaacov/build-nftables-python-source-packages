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

validate_python() {
  if ! command -v python >/dev/null 2>&1; then
    echo "Error: python executable not found" >&2
    exit 1
  fi

  if ! python -c "import build" >/dev/null 2>&1; then
    echo "Error: python does not have the 'build' module installed" >&2
    exit 1
  fi
}

print_python_version() {
    python -V
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

tag_to_version() {
    local tag="$1"
    echo "${TAG}" | sed 's/^v//'
}

build_package() {
    local TEMP_DIR="$1"
    local DIST_DIR="$2"
    local TAG="$3"
    local VERSION="$(tag_to_version "${TAG}")"
    local PACKAGE_DIR="${TEMP_DIR}/package-${VERSION}"
    local PACKAGE_NAME="nftables-${VERSION}.tar.gz"
    
    echo "building nftables ${TAG} source package"
    
    cd py
    python -m build
    mv ./dist "${DIST_DIR}/nftables-${TAG}"
    cd -
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
    validate_python
    print_python_version
    local WORKING_DIR
    WORKING_DIR="$(realpath "$1")"
    prepare_directories "${WORKING_DIR}"
    clone_repository "${WORKING_DIR}"
    cd "${WORKING_DIR}/temp/nftables" || exit 1
    build_packages "${WORKING_DIR}"
    cleanup "${WORKING_DIR}"
}

main "$@"

