#!/bin/bash

function usage() {
    echo "Usage: $0 [...pkg_dir]"
    echo "       cat <pkg_dir_list> | $0"
    echo "       $0 < <pkg_dir_list>"
    echo "       $0 [...pkg_dir] < <pkg_dir_list>"
}

cur_dir="$(pwd)"

args=()
for item in "$@"; do
    args+=("$item")
done
if [ ! -t 0 ]; then
    while read -r pkg_dir || [[ -n "$pkg_dir" ]]; do
        cd "$cur_dir"
        pkg_dir=$(echo "$pkg_dir" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g')
        [ -z "$pkg_dir" ]  && continue
        args+=("$pkg_dir")
    done
fi

if [ ${#args[@]} -eq 0 ]; then
    usage
    exit 0
fi

function fixone() {
    pkg_dir="$1"
    pkg_dir=$(echo "$pkg_dir" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g')
    [ -z "$pkg_dir" ]  && continue
    [ ! -d "$pkg_dir" ] && echo "\"$pkg_dir\" is not a directory, skip" && return 1
    [ ! -f "$pkg_dir/Makefile" ] && echo "Makefile not found in \"$pkg_dir\", skip" && return 1

    cd "$pkg_dir"

    echo "Fixing \"$(pwd)\""

    if grep -q "^[ \t]*PKG_BUILD_DEPENDS:=" Makefile; then
        # Has `PKG_BUILD_DEPENDS:=`
        if grep -q "^[ \t]*PKG_BUILD_DEPENDS:=.*upx/host" <<< Makefile; then
            # if `upx/host` already exists, skip
            echo "Nothing to do in \"$pkg_dir\""
            continue
        else
            # if `upx/host` not exists, add it
            depends=$(sed -n '/^[ \t]*PKG_BUILD_DEPENDS:=/s/^[ \t]*PKG_BUILD_DEPENDS:=//p' Makefile | sed -e 's/[ \t]*$//')
            depends=$(echo "$depends" | sed -e 's/[]\/$*.^|[]/\\&/g')
            [ ${#depends} -gt 0 ] && depends="$depends "
            sed -i "/^[ \t]*PKG_BUILD_DEPENDS:=/s/:=.*$/:=${depends}upx\/host/" Makefile
        fi
    else
        if ! grep -q "^[ \t]*PKG_" Makefile; then
            # No any `PKG_`, add to head
            sed -i '1i PKG_BUILD_DEPENDS:=upx/host' Makefile
        else
            # Find a `PKG_`, insert after it, once only
            sed -i '/^[ \t]*PKG_/ {a PKG_BUILD_DEPENDS:=upx/host
                ;:a;n;ba}' Makefile
        fi
    fi

    cd "$cur_dir"
    return 0
}

for item in "${args[@]}"; do
    fixone "$item"
done

cd "$cur_dir"