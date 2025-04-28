# Nftables Python Source Packager

## Overview

This shell script automates the process of cloning the [nftables](https://git.netfilter.org/nftables) repository, fetching all Git tags, and creating a compressed Python source package (`.tar.gz`) for each release.

Each `.tar.gz` archive will contain the Python source code from the `py/` directory of the respective nftables tag. All packages are collected into a `dist` directory.

## Features

- Clones the official nftables repository
- Fetches all Git tags
- Creates a clean `.tar.gz` package of Python sources for each version
- Organizes output in a `dist` folder
- Cleans up temporary files after execution

## Requirements

- git
- tar
- realpath
- Shell environment that supports POSIX sh

## Usage

```sh
./builder.sh <working_directory>
```

### Parameters

- `working_directory`: Path where the script will create:
  - `temp` directory for cloning and processing
  - `dist` directory for storing the generated `.tar.gz` files

### Example

```sh
./builder.sh /tmp/nftables_build
```

After running, you will find a `.tar.gz` package for each nftables tag in the `/tmp/nftables_build/dist/` directory.

## Help

If incorrect parameters are supplied, the script will display detailed usage instructions automatically.

## Notes

- The resulting `.tar.gz` packages are simple archives of the `py/` source code.
- They are **not** pip-installable Python packages unless a `setup.py` or `pyproject.toml` is manually added.
- The script is designed for a clean, professional build process, adhering strictly to POSIX sh standards.
