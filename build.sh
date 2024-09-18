#!/bin/bash

# Constants
codebase_root_dir="W:"

# Parse command line
for arg in "$@"; do declare "$arg"=1; done

# @todo: Yadda yadda yadda add whatever option handling we want here
if [[ "$release" == "" ]]; then
  mode_debug=1
  echo "[Debug mode]"
else
  echo "[Release mode]"
fi

debug_defines="-DENABLE_ASSERT=1"
if [[ "$clang" == "" ]] || [[ "$msvc" == 1 ]]; then
  echo "[MSVC compile]"
  debug="-Od -Zi -WX $debug_defines"
  release="-O2"
  common="cl -nologo -FC -J -I"$codebase_root_dir"/code -EHa- -GR- -W3 -wd4146 -wd4005 -wd4101"
  link=""
  out="-Fe"
else
  echo "[Clang compile]"
  debug="-O0 -g -Werror -Wall $debug_defines"
  release="-O2"
  common="clang -pedantic"
  link=""
  out="-o"
fi

jai_compile="jai -debugger -output_path $codebase_root_dir/build -quiet" # Most things will be handled by metaprogram

# @todo: Set per-build settings like 'only-compile', 'assemble', etc

# Setup requested config
if [[ "$mode_debug" == 1 ]]; then
  compile="$common $debug"
else
  compile="$common $release"
fi
link="$link"
out="$out"

# Prep build dirs
mkdir -p build

# @todo: C metagen

# Build
pushd build >> /dev/null
built=0
if [[ "$dumb" == 1 ]]; then built=1 && eval "$compile $codebase_root_dir"/code/dumb/main.c "$link User32.lib Gdi32.lib $out"dumb.exe || exit 1; fi
if [[ "$debaser" == 1 ]]; then built=1 && eval "$jai_compile $codebase_root_dir"/code/debaser/debaser.jai || exit 1; fi
if [[ "$llvm_example" == 1 ]]; then built=1 && eval "$compile $codebase_root_dir"/code/llvm_example/main.cpp "$link $out"llvm_example.exe || exit 1; fi
if [[ "$d3d11_playground" == 1 ]]; then built=1 && eval "$compile $codebase_root_dir"/code/d3d11_playground/main.c "$link User32.lib Gdi32.lib d3d11.lib $out"d3d11_playground.exe || exit 1; fi

if [[ "$built" == 0 ]]; then echo "Unrecognized target!"; fi
popd >> /dev/null