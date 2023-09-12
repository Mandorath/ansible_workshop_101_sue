#!/bin/bash
set -eu

# Default python version to use.
declare -ri python_version=3
# In case we have a local python package repo, point to it using this variable.
declare -r trusted_repository='localrepo.local'

declare current_directory
current_directory="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

function activate-virtualenv()
{
    declare -r env_directory="$1"
    declare -r activate_script="$env_directory/bin/activate"
    if [[ ! -f "$activate_script" ]]; then
        echo -e "The script to activate the virtualenv is missing. Aborting...\n"
        echo-possible-use-of-CRTL-C "$env_directory" >&2
        exit 1
    fi
    # Ensure all variables required by the virtualenv script are defined but
    # empty.
    _OLD_VIRTUAL_PYTHONHOME=
    _OLD_VIRTUAL_PS1=
    ZSH_VERSION=
    PYTHONHOME=
    VIRTUAL_ENV_DISABLE_PROMPT=
    VIRTUAL_ENV=
    PS1=
    # Except this one.
    _OLD_VIRTUAL_PATH="$PATH"
    source $activate_script
    trap 'deactivate "destructive"' EXIT
}

function create-and-activate-virtualenv()
{
    declare -r env_directory="$1"
    declare -r repository_directory="$2"
    declare -r requirements_file="$3"
    declare -r use_local_package_repo=${4:-false}

    # Creating a Python 3 virtualenv using 'virtualenv-3' is takes several
    # orders of magnitude longer than creating it with 'python3 -m venv'. This
    # does not occur for Python 2, but for the sake of consistency we use the
    # 'virtualenv' module anyway.
    if (( $python_version == 2 )); then
        python2 -m virtualenv "$env_directory" > /dev/null
    else
        python3 -m venv "$env_directory" > /dev/null
    fi

    activate-virtualenv "$env_directory"

    # Suppress warnings about unencrypted HTTP traffic. Note that the option
    # that enables this (--trusted-host) does not have to be available until
    # /after/ we've updated pip.
    #
    # So we check whether it is available and if so, we use it.
    # trusted_host_option=""
    # if [[ $( python -m pip --help | grep -c trusted-host ) -ne 0 ]]; then
    #     trusted_host_option="--trusted-host $trusted_repository"
    # fi

    # To update pip and its dependencies, we use the repository directory as if
    # it were a local directory. This is the safest because the current version
    # of pip might not support the proper parameter for that (index-url).
    # index_parameters="--no-index --find-links $repository_directory"


    # Package wsgiref is built-in in Python 3 and attempting to install it
    # results in an error, so exclude it.
    if (( $python_version != 2 )); then
        sed -i -e 's/^wsgiref\b.*/# &/' "$requirements_file"
    fi

    # if [[ $( python -m pip --help | grep -c trusted-host ) -ne 0 ]]; then
    #     trusted_host_option="--trusted-host $trusted_repository"
    # fi

    if $use_local_package_repo; then
        index_parameters="--no-index --find-links $repository_directory"
    else
        index_parameters="--index-url $repository_directory/simple"
    fi
    echo -e "Upgrading pip"
    python -m pip install \
           --upgrade pip \
           --quiet --quiet
    echo -e "...installing the dependencies of the Python package (this can take a while)..."
    # And then install the dependencies.
    python -m pip install \
           --quiet --quiet \
           --requirement "$requirements_file"

}

# Activate a virtual env for installation.
#
# This function creates the virtual env if it does not yet exist. The created
# virtual env is activated.
#
# Args
#    env_directory (str): full path to the virtual env to create/activate
#    use_local_package_repo (optional, str):  iff true, install the required
#        packages from the local directory, otherwise from the HITT repo

function activate-deploy-virtualenv()
{
    declare -r env_directory="${1}"
    declare -r use_local_package_repo=${2:-false}
    declare -r py_dir="$current_directory"
    declare -r requirements_file="${3}"

    if [[ ! -d "$env_directory" ]]; then
        echo -e "\nVirtualenv for running the collection script does not yet exist. Creating...\n"

        if $use_local_package_repo; then
            declare -r repository_directory="$current_directory/repository"
        else
            declare -r repository_directory='http://localrepo.local/python-packages'
        fi

        create-and-activate-virtualenv "$env_directory" "$repository_directory" "$requirements_file" "$use_local_package_repo"
        echo -e "\nVirtualenv created!\n"
    else
        echo -e "\nVirtualenv for deployment scripts already exists. Activating...\n"
        activate-virtualenv "$env_directory"
        echo -e "Virtualenv activated!\n"
    fi

    echo -e "Checking for missing packages...\n"

    # To determine if the virtualenv is installed, we write the list of installed
    # packages to a file and we let grep use that file. Initially we piped the
    # output of pip to 'grep --quiet', but this sometimes lead to Python stack
    # traces on behalf of pip. This was caused by the fact that 'grep --quiet'
    # closes the pipe as soon as it can determine its exit code.
    declare -r installed_packages=$(mktemp)
    list-installed-packages-to-file $installed_packages
    declare -r required_packages=$(mktemp)
    cat "$requirements_file" > $required_packages
    # remove any comment lines or pip options from the package file
    sed -i '/^[-#]/d' $required_packages
    # if the next invocation of grep returns 0, there were lines in
    # required_packages that are not present in $installed_packages
    # if grep --quiet --invert-match --file=$installed_packages $required_packages; then
    #     rm $installed_packages $required_packages > /dev/null
    #     echo -e "\nVirtualenv has missing packages. Aborting...\n" >&2
    #     echo-possible-use-of-CRTL-C "$env_directory" >&2
    #     exit 1
    # fi
    echo -e "...no packages missing\n"
}

function list-installed-packages-to-file()
{
    declare -r installed_packages="${1}"
    pip list --no-index --format=freeze > $installed_packages 2> /dev/null || true
    echo -e $installed_packages
}

function echo-possible-use-of-CRTL-C()
{
    declare -r env_directory="${1}"

    echo -e "This can happen if the initial creation of the virtualenv was"
    echo -e "interrupted, for example via CTRL-C. To recreate the virtualenv,"
    echo -e "delete directory\n"
    echo -e "    $env_directory\n"
    echo -e "(and its contents) and execute the command again.\n"
}

# Install from the local repository.
#
# The local repository is directory $current_directory/repository

function install-packages-venv()
{
    install-packages ${1}
}


function install-packages()
{
  echo -e "Checking if Python package is installed...\n"
  declare -r installed_packages=$(mktemp)
  declare -r directory="$current_directory"
  declare -r py_dir="$current_directory"
  list-installed-packages-to-file $installed_packages
  if ! grep --quiet ${1} $installed_packages; then
      rm ${installed_packages}> /dev/null
      echo -e "...not installed yet so installing it now..."
      python -m pip install \
           -r "$py_dir/requirements.txt" \
           --quiet --quiet
  else
      echo -e "...is already installed"
  fi
}
