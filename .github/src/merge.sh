#!/bin/bash

# Merge packages into a directory

function usage() {
    echo "Usage: merge <...sources> [options]"
    echo "Usage: merge <destination> <...sources> [options]"
    echo "Options:"
    echo "  * -d, --destination <dst>     Destination directory"
    echo "    -n, --no-clobber            Do not overwrite an existing file"
    echo "    --move                      Move files instead of copying"
    echo "    --reverse-priority          Reverse the priority of the source directory"
    echo "    --retain-files              Directories will not cover files with the same name"
    echo "    -h, --help                  Show this help message and exit"
    echo "Note: Options marked * is required for the first usage"
    echo "Note: The default pirority of the source directory is from left to right"
}

_RED=`echo -en "\033[31m"`
_GREEN=`echo -en "\033[32m"`
_YELLOW=`echo -en "\033[33m"`
_RESET=`echo -en "\033[0m"`

destination=
opt_overwrite=true
opt_move=false
opt_reverse_priority=false
opt_retain_files=false
sources=()

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--destination)
            if [ $# -lt 2 ] || [[ "$2" =~ ^-+ ]]; then
                echo "$_RED""Error: missing destination directory for $1""$_RESET"
                exit 1
            fi
            destination="$2"
            shift
            ;;
        -n|--no-clobber)
            opt_overwrite=false
            shift
            ;;
        --move)
            opt_move=true
            shift
            ;;
        --reverse-priority)
            opt_reverse_priority=true
            shift
            ;;
        --retain-files)
            opt_retain_files=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "$_RED""Error: unknown option '$1'""$_RESET"
            exit 1
            ;;
        *)
            sources+=("$1")
            shift
            ;;
    esac
done

# check destination
if [ -z "$destination" ]; then
    destination="${sources[0]}"
    unset sources[0]
fi
# check sources
if [ ${#sources[@]} -eq 0 ]; then
    echo "$_RED""Error: no source directory specified""$_RESET"
    exit 1
fi
if [ "${#sources[@]}" -eq 1 ] && [ "$destination" = "${sources[0]}" ]; then
    echo "$_RED""Error: destination directory is the same as source directory""$_RESET"
    exit 1
fi

# convert to real path
destination="$(realpath "$destination")"
for i in "${!sources[@]}"; do
    sources[$i]="$(realpath "${sources[$i]}")"
done

# move command
if [ $opt_overwrite = true ]; then
    if [ $opt_move = true ]; then
        MOVEC="mv -f"
    else
        MOVEC="cp -rf"
    fi
else
    if [ $opt_move = true ]; then
        MOVEC="mv -n"
    else
        MOVEC="cp -rn"
    fi
fi
[ $opt_move = true ] && MOVE_VERB="Moving" || MOVE_VERB="Copying"
function TRANSPORT() {
    local src="$1"
    [ -z "$src" ] && return 1
    local name="$2"
    [ -z "$name" ] && name="$(basename "$src")"
    local dst="$destination/$name"
    if [ "$opt_overwrite" = false ] && [ -d "$dst" ]; then
        [ "$name" = "$(basename "$src")" ] \
        &&  echo "Ignoring \"$src\"..." \
        ||  echo "Ignoring \"$src\" ($name)..."
        return 0
    fi

    if [ -e "$destination" ]; then
        rm -rf "$dst"
    else
        mkdir -p "$destination"
    fi
    [ "$name" = "$(basename "$src")" ] \
    &&  echo "$MOVE_VERB \"$src\"..." \
    ||  echo "$MOVE_VERB \"$src\" ($name)..."
    $MOVEC "$src" "$dst"
}

# map
keys=()
function contains_keys() {
    local val="$1"
    local i
    for i in "${!keys[@]}"; do
        if [ "${keys[$i]}" = "$val" ]; then
            return 0
        fi
    done
    return 1
}
function remove_keys() {
    local val="$1"
    local i
    for i in "${!keys[@]}"; do
        if [ "${keys[$i]}" = "$val" ]; then
            unset keys[$i]
            return 0
        fi
    done
    return 1
}
function escape_string() {
    local str="$1"
    echo -n "$str" | sed 's/\"/\\\"/g'
}
function sha256() {
    local str="$1"
    echo -n "$str" | sha256sum | awk '{print $1}'
}
function set_value() {
    local key="$1"
    local hash_key="$(sha256 "$key")"
    local value="$(escape_string "$2")"
    local global_var_name="map_${hash_key}_"
    eval "declare -g $global_var_name=\"$value\""
    if ! contains_keys "$key"; then
        keys+=("$key")
    fi
}
function get_value() {
    local key="$1"
    local hash_key="$(sha256 "$key")"
    local global_var_name="map_${hash_key}_"
    eval "echo -n \"\$$global_var_name\""
}
function unset_key() {
    local key="$1"
    local hash_key="$(sha256 "$key")"
    local global_var_name="map_${hash_key}_"
    eval "unset $global_var_name"
    remove_keys "$key"
}

# crate index
function crate_index() {
    local src="$1"
    [ -z "$src" ] && return 1
    if [ ! -d "$src" ]; then
        echo "$_YELLOW""Warning: source directory '$src' does not exist""$_RESET"
        return 1
    fi
    if [ "$destination" = "$src" ]; then
        return 0
    fi

    local pkg_path pkg_name
    for pkg_path in $(find "$src" -maxdepth 1 -mindepth 1 -type d); do
        pkg_name=$(basename "$pkg_path")

        if [ "$opt_retain_files" = true ]; then
            if [ -f "$destination/$pkg_name" ]; then
                echo "$_YELLOW""Ignored package '$pkg_name', for destination directory has a file with the same name""$_RESET"
                continue
            fi
        fi

        if [ -z "$(get_value "$pkg_name")" ]; then
            echo "Found package '$pkg_name', adding to tasks"
            set_value "$pkg_name" "$pkg_path"
        elif [ "$opt_reverse_priority" = true ]; then
            echo "Found package '$pkg_name', replacing with higher priority"
            set_value "$pkg_name" "$pkg_path"
        else
            echo "Ignored package '$pkg_name', for it has been added"
        fi
    done
}

for src in "${sources[@]}"; do
    crate_index "$src"
done

for key in "${keys[@]}"; do
    TRANSPORT "$(get_value "$key")" "$key"
done