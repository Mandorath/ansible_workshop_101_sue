#!/bin/bash
# Setup ansible pyenv
set -eu

declare scripts_directory
scripts_directory="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source_dir="${scripts_directory}/venv_setup"
source "${source_dir}/virtualenv-lib.bash"
test_package="ansible"
requirements_file="${source_dir}/requirements.txt"

function main()
{
    declare -r env_directory="$scripts_directory/env${python_version}"
    declare -r use_local_package_repo=false

    activate-deploy-virtualenv "$env_directory" $use_local_package_repo "$requirements_file"

    install-packages-venv $test_package

    source env3/bin/activate
    echo "Ansible version in pyenv:"
    ansible --version
    echo "Python version in pyenv environment:"
    python --version
    which python
}

main "$@"
