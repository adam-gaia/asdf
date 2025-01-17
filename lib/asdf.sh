# The asdf function is a wrapper so we can export variables
asdf() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "${command}" in
  "update")
    echo "You don't want to update this way. This is a forked version of asdf the update call wont work"
    echo "    Instead, rebase with the main repo"
    return 1
    ;;

  "shell")
    # commands that need to export variables
    eval "$(asdf export-shell-version sh "$@")" # asdf_allow: eval
    ;;

  *)
    # forward other commands to asdf script
    command asdf "${command}" "$@"
    ;;

  esac


  # Run post-command patches. Bash switch-case fallthrough and continue didn't seem to work in zsh
  case "${command}" in
  "reshim")
    # After running 'asdf reshim' create symlinks
    target_dir="/usr/local/bin"
    shims=($(find "${ASDF_USER_SHIMS}" -executable -type f))

    for shim in ${shims[@]}; do
      base="$(basename "${shim}")"
      target="${target_dir}/${base}"

      # Check if target is already a symlink
      if [[ -L "${target}" ]]; then

        if [[ -e "${target}" ]]; then
          # Resolve the target and check if it maches what we want to link it to
          current_source="$(realpath "${target}")"
          if [[ "${current_source}" == "${shim}" ]]; then
            echo "SUCCESS: ${shim} is already linked to ${target}"
          else
            echo "ERROR:  ${target} is already a symlink to '${current_source}'. Could not link to '${shim}'"
          fi
          continue

        else
          # Existing symlink is broken. Remove it, but ask for permission
          command rm -i "${target}"
        fi

      elif [[ -e  "${target}" ]]; then
        echo "ERROR: Symlink target ${target} already exists and is a valid file."
        echo "    You should probably figure out how it was installed and remove it"
        continue
      fi

        sudo -p "[sudo] Sudo privlileges needed to creat a symlink in directory '${target_dir}': " ln -s "${shim}" "${target}" && echo "SUCCESS: Linked ${target} to ${shim}" || echo "ERROR: Failed while linking ${target} to ${shim}"
    done
    ;;

  esac
}
