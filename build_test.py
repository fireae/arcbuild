# The MIT License (MIT)
# Copyright © 2016 Naiyang Lin <maxint@foxmail.com>

import os
import subprocess
import shutil
import glob
import sys


def build(platform, root=None, source_dir=None, binary_dir=None, suffix=None):
    args =[
        '-DPLATFORM=%s' % platform,
        '-DTYPE=SHARED',
        '-DVERBOSE=3',
    ]
    args += ['-DROOT=%s' % root] if root else []
    args += ['-DSOURCE_DIR=%s' % source_dir] if source_dir else []
    args += ['-DBINARY_DIR=%s' % binary_dir] if binary_dir else []
    args += ['-DSUFFIX=%s' % suffix] if suffix else []
    args += ['-P', 'arcbuild.cmake']
    args = ['cmake'] + args
    subprocess.check_call(' '.join(args), shell=True)


def batch_build(platforms, root=None, source_dir=None, binary_dir=None, suffix=None):
    for platform in platforms:
        build(platform,
            root if platform=='android' else None,
            source_dir, binary_dir, suffix)


def main():
    if os.name == 'nt':
        root = r'E:\NDK\android-ndk-r11b'
        os.environ['PATH'] += r';{0}\CMake\bin'.format(os.environ['ProgramFiles(x86)'])
    else:
        root = None

    # print os.environ['PATH']
    if os.name == 'nt':
        platforms = ['android', 'vs2015', 'vs2013']
    else:
        platforms = ['linux']

    map(os.remove, glob.glob('*.zip'))
    shutil.rmtree('_build', ignore_errors=True)

    examples = os.listdir('examples')
    examples.remove('local')

    for name in examples:
        batch_build(platforms, root, 'examples/{0}'.format(name), '_build/{0}'.format(name), '_{0}'.format(name))

    old_dir = os.getcwd()
    try:
        os.chdir('examples/local')
        shutil.copy('../../arcbuild.cmake', '.')
        map(os.remove, glob.glob('*.zip'))
        shutil.rmtree('_build', ignore_errors=True)
        shutil.rmtree('_arcbuild', ignore_errors=True)
        batch_build(platforms, root, suffix='_local')
        for path in glob.glob('*.zip'):
            shutil.copy(path, '../..')
    finally:
        os.chdir(old_dir)

    # total_sdk_build = len(examples) * len(platforms)
    total_sdk_build = len(platforms)
    total_sdk_pkg = len(glob.glob('*.zip'))
    if total_sdk_pkg != total_sdk_build:
        raise Exception("The number of SDK's (%d) is not correct (%d)!" % (total_sdk_pkg, total_sdk_build))

if __name__ == '__main__':
    try:
        sys.exit(int(main() or 0))
    finally:
        if os.name == 'nt':
            os.system('pause')
