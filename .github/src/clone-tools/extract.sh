#!/bin/bash
# Extract packages from a repository

mvcp_opt="-f"
remove_repo=false
remaining_args=()
specify=false
specify_args=()
destination="."
function usage() {
    echo "Usage: $0 [options] [...repository]"
    echo "Note: if repository is not specified, it will turn on git-stdin mode"
    echo "Options:"
    echo "    -d, --destination <directory>    Specify destination directory"
    echo "                                     (Default) ."
    echo "    -n, --no-clobber                 Do not overwrite existing files"
    echo "    -r, --remove                     Remove repository after extraction"
    echo "    -s, --specify <...[~]package>    Specify packages to extract"
    echo "    -h, --help                       Show this help message"
    echo "Note: If only packages starting with ~ are specified, all packages will be extracted except them"
    echo "Note: Do not use syntax like --specify <..package> [...repository]"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h |\
        --help)
            usage
            exit 0
            ;;
        -d |\
        --destination)
            [ -z "$2" ] || [[ "$2" =~ ^- ]] && echo "Missing argument for $1" && exit 1
            destination="$2"
            shift 2
            ;;
        -n |\
        --no-clobber)
            mvcp_opt="-n"
            shift
            ;;
        -r |\
        --remove)
            remove_repo=true
            shift
            ;;
        -s |\
        --specify)
            # read until next option
            specify=true
            shift
            while [[ $# -gt 0 ]]; do
                [[ "$1" =~ ^- ]] && break
                specify_args+=("$1")
                shift
            done
            [ ${#specify_args[@]} -eq 0 ] && echo "Missing argument for $1" && exit 1
            ;;
        -* |\
        --*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            remaining_args+=("$1")
            shift
            ;;
    esac
done

[ ${#remaining_args[@]} -eq 0 ] && stdin_mode=true || stdin_mode=false

blacklist=(.git .github .vscode .idea .DS_Store)
function escape_regex() {
    echo "$1" | sed 's/[]\/$*.^|[]/\\&/g'
}
function is_blacklisted() {
    local pkg="$1"
    local black
    for black in "${blacklist[@]}"; do
        black="$(escape_regex "$black")"
        [[ "$pkg" =~ ^$black$ ]] && return 0
    done
    return 1
}

ignored_packages=()
included_packages=()
[ ${#specify_args[@]} -gt 0 ] && {
    for arg in "${specify_args[@]}"; do
        if [[ "$arg" =~ ^~ ]]; then
            ignored_packages+=("${arg:1}")
        else
            included_packages+=("$arg")
        fi
    done
}

tmphash=$(echo "$(date +%s%N).${ignored_packages[@]}" | md5sum | sed 's/[^0-9a-zA-Z]//g' | cut -c 1-8)
tmpdir="/tmp/extract-$tmphash"
mkdir -p "$tmpdir"

create_tmpdir() {
    mkdir -p "$tmpdir/$1"
    echo "$tmpdir/$1"
}
clean_tmpdir() {
    rm -rf "$tmpdir/$1"
}
function move_ignored() {
    local src="$1"
    local cur_dir="$(pwd)"
    local src_dir="$(realpath "$src")"
    [ "$remove_repo" = true ] || local mv_tmpdir="$(create_tmpdir "$src_dir")"
    for ignored_pkg in "${ignored_packages[@]}"; do
        if [ -e "$src_dir/$ignored_pkg" ]; then
            [ "$remove_repo" = true ] && \
            rm -rf "$src_dir/$ignored_pkg" || \
            mv -f "$src_dir/$ignored_pkg" "$mv_tmpdir/"
        fi
    done
    return 1
}
function restore_ignored() {
    local src="$1"
    local cur_dir="$(pwd)"
    local src_dir="$(realpath "$src")"
    [ ! "$remove_repo" = true ] && {
        local mv_tmpdir="$(create_tmpdir "$src_dir")"
        mv -f "$mv_tmpdir"/* "$src_dir/"
    }
    clean_tmpdir "$src_dir"
}

function extract_pkg() {
    local src="$1"
    local dst="$destination"
    [ -n "$2" ] && dst="$2"
    if [ -d "$src" ]; then
        [ -f "$dst" ] && echo "$dst is not a directory" && return 1
        [ -d "$dst" ] || mkdir -p "$dst"
        local cur_dir="$(pwd)"
        local src_dir="$(realpath "$src")"
        local dst_dir="$(realpath "$dst")"
        echo "Extracting packages from \"$src_dir\"$([ -n "$2" ] && echo " to \"$dst_dir\"")..."

        local loop_dir=()
        if [ ${#included_packages[@]} -eq 0 ]; then
            for ii in $(find "$src_dir/"* -mindepth 0 -maxdepth 0 -type d -exec basename {} \;) ; do
                is_blacklisted "$ii" && continue
                loop_dir+=("$ii")
            done
        else
            local p
            for p in "${included_packages[@]}"; do
                # quote spaces with "" in $p, escape "
                path="$(echo "$p" | sed 's/  */"&"/g' | sed 's/"/\\"/g')"
                local ii
                for ii in $(find "$src_dir"/$path -mindepth 0 -maxdepth 0 -type d -exec bash -c "echo \"{}\" | cut -c $((${#src_dir}+2))-" \;) ; do
                    is_blacklisted "$ii" && continue
                    loop_dir+=("$ii")
                done
            done
        fi

        move_ignored "$src_dir"
        local pkg_name
        for pkg_name in "${loop_dir[@]}"; do
            is_blacklisted "$pkg_name" && continue
            [ ! -d "$src_dir/$pkg_name" ] && continue
            local final_pkg_name="$(basename $pkg_name)"
            local appendix="" && { [ "$pkg_name" == "$final_pkg_name" ] || appendix=" ($pkg_name)"; }
            echo "Extracting package $final_pkg_name$appendix..."
            [ "$remove_repo" = true ] && \
            mv $mvcp_opt    "$src_dir/$pkg_name" "$dst_dir/$final_pkg_name" || \
            cp $mvcp_opt -r "$src_dir/$pkg_name" "$dst_dir/$final_pkg_name"
        done
        restore_ignored "$src_dir"
        [ "$remove_repo" = true ] && {
            echo "Removing \"$src_dir\"..."
            rm -rf "$src"
        }
    else
        echo "$src is not a directory" && return 1
    fi
}


if [ "$stdin_mode" = true ]; then
    found=false
    while IFS= read -r line; do
        echo "$line" >&2
        [ $found = false ] && {
            if [[ "$line" =~ \'\.\.\.$ ]]; then
                repo="$(echo "$line" | awk -F "'" '{print $2}')"
                found=true
            fi
        }
    done
    extract_pkg "$repo"
else
    for repo in "${remaining_args[@]}"; do
        extract_pkg "$repo"
    done
fi