from distutils.dir_util import copy_tree
import os
import re
import shutil
import sys

def files(directory):
    return (f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f)))

def copy_files(source, destination):
    os.makedirs(destination, exist_ok=True)

    module_src_dir = os.path.join(source, "Modules")
    module_dst_dir = os.path.join(destination, "Modules")

    os.mkdir(module_dst_dir)

    for f in files(module_src_dir):
        src_path = os.path.join(module_src_dir, f)
        dst_path = os.path.join(module_dst_dir, f)

        shutil.copyfile(src_path, dst_path)

    for f in files(source):
        src_path = os.path.join(source, f)
        dst_path = os.path.join(destination, f)

        shutil.copyfile(src_path, dst_path)

def unique(list1): 
    unique_list = [] 

    for x in list1: 
        if x not in unique_list: 
            unique_list.append(x)
    
    return unique_list

def get_libs(src_directory):
    embeds = os.path.join(src_directory, "embeds.xml")

    text = ""

    with open(embeds, 'r') as file:
        text = file.read()

    matches = re.findall("file=\"([\\S]+)\"", text)

    return unique((os.path.dirname(m) for m in matches))

def main(args):
    if (len(args) < 4):
        print("missing required arguments <src dir>, <release dir> <project name>")
        exit(1)

    src_directory = args[1]
    release_directory = args[2]
    project_name = args[3]
    
    project_directory = os.path.join(release_directory, project_name)

    os.mkdir(project_directory)

    copy_files(src_directory, project_directory)

    libs = get_libs(src_directory)

    for lib in libs:
        copy_tree(os.path.join(src_directory, lib), os.path.join(project_directory, lib))

if __name__ == '__main__':
    main(sys.argv)