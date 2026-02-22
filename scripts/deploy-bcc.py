from shutil import rmtree, copytree
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
        "_anniversary_",
        "Interface",
        "AddOns",
        project_name,
    )

    print(src_directory)
    print(dst_directory)

    if os.path.exists(dst_directory):
        rmtree(dst_directory)

    os.mkdir(dst_directory)

    copytree(src_directory, dst_directory, dirs_exist_ok=True)


if __name__ == "__main__":
    main(sys.argv)
