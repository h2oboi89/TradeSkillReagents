from distutils.dir_util import copy_tree
from shutil import rmtree
import os
import sys


def main(args):
    if len(args) < 3:
        print("missing required arguments <src dir>, <release dir> <project name>")
        exit(1)

    release_directory = args[1]
    project_name = args[2]

    src_directory = os.path.join(release_directory, project_name)
    dst_directory = os.path.join(
        "C:",
        "Program Files (x86)",
        "World of Warcraft",
        "_classic_era_",
        "Interface",
        "AddOns",
        project_name,
    )

    print(src_directory)
    print(dst_directory)

    if os.path.exists(dst_directory):
        rmtree(dst_directory)

    os.mkdir(dst_directory)

    copy_tree(src_directory, dst_directory)


if __name__ == "__main__":
    main(sys.argv)
