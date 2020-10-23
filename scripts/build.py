import os
import re
import shutil
import sys

def exists(directory, name):
    if not os.path.exists(directory) and not os.path.isdir(directory):
        print(f"{name} directory does not exist or is not a directory")
        exit(1)

def files(directory):
    return (f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f)))

def copy_files(source, destination):
    os.makedirs(destination, exist_ok=True)

    for f in files(source):
        src_path = os.path.join(source, f)
        dst_path = os.path.join(destination, f)

        shutil.copyfile(src_path, dst_path)

def get_libs(src_directory):
    embeds = os.path.join(src_directory, "embeds.xml")

    text = ""

    with open(embeds, 'r') as file:
        text = file.read()

    matches = re.findall("file=\"([\S]+)\"", text)

    return (os.path.dirname(m) for m in matches)

def main(args):
    if (len(args) < 4):
        print("missing required arguments <src dir>, <release dir> <project name>")
        exit(1)

    src_directory = args[1]
    release_directory = args[2]
    project_name = args[3]
    project_folder = os.path.join(release_directory, project_name)

    exists(src_directory, "source")
    exists(release_directory, "release")

    os.mkdir(project_folder)

    copy_files(src_directory, project_folder)

    libs = get_libs(src_directory)

    for lib in libs:
        copy_files(os.path.join(src_directory, lib), os.path.join(project_folder, lib))

if __name__ == '__main__':
    main(sys.argv)