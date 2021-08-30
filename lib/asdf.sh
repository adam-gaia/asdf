# The asdf function is a wrapper so we can export variables
asdf() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  "shell")
    # commands that need to export variables
    eval "$(asdf export-shell-version sh "$@")" # asdf_allow: eval
    ;;
  *)
    # forward other commands to asdf script
    command asdf "$command" "$@"
    ;;& # Resume to catch any other matches
  "reshim")
    # After running 'asdf reshim' create symlinks
    target_dir="${HOME}/.local/bin"
    shims=$(find "${ASDF_BIN}" -executable)

    for x in ${shims[@]}; do
        base="$(basename "${shim}")"
        target="${target_dir}/${base}"

        # Check if target is already a valid symlink
        if [[ -L "${target}" ]]; then
            # Resolve the target and check if it maches what we want to link it to
            current_source="$(realpath "${target}")"
            if [[ "${current_source}" == "${shim}" ]]; then
                echo "SUCCESS: ${shim} is already linked to ${target}"
            else
                echo "ERROR:  ${target} is already a symlink to '${current_source}'. Could not link to '${shim}'"
            fi
            continue
 
        elif [[ -l "${target}" ]]; then
            # Existing symlink is broken. Remove it.
            rm "${target}"

        else
            echo "ERROR: Symlink target ${target} already exists and is a valid file."
            echo "    You should probably figure out how it was installed and remove it"
            continue
        fi
        
        ln -s "${shim}" "${target}" && echo "SUCCESS: Linked ${target} to ${shim}" || echo "ERROR: Failed while linking ${target} to ${shim}"
    done
    ;;

  esac
}
