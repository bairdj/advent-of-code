import os
class File:
    def __init__(self, name: str, size: int, directory: 'Directory'):
        self.name = name
        self.size = size
        self.directory = directory

class Directory:
    def __init__(self, name, parent=None):
        self.name = name
        self.subdirectories = []
        self.files = []
        self.parent = parent

    def print_structure(self):
        print(f"{self.get_full_path()} ({self.get_size()})")
        for subdirectory in self.subdirectories:
            subdirectory.print_structure()

    def get_size(self):
        size = 0
        for subdirectory in self.subdirectories:
            size += subdirectory.get_size()
        for file in self.files:
            size += file.size
        return size

    def directory_from_components(self, components: list):
        if len(components) == 0:
            return self
        else:
            for subdirectory in self.subdirectories:
                if subdirectory.name == components[0]:
                    return subdirectory.directory_from_components(components[1:])
            return None

    def get_full_path(self):
        if self.parent is None:
            return self.name
        else:
            return '/'.join([self.parent.get_full_path(), self.name])

    def __str__(self):
        return self.get_full_path()


class FileSystem:
    def __init__(self):
        self.root = Directory('/')
        self.current_directory = self.root

    def directory_from_path(self, path: str):
        if path == '/':
            return self.root
        components = path.split('/')
        return self.root.directory_from_components(components)


input_file = os.path.join(os.path.dirname(__file__), 'input.txt')

with open(input_file, 'r') as f:
    fs = FileSystem()
    lines = f.readlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        # Check if line is a command
        if line.startswith('$'):
            # Extract the command
            command = line[1:].strip().split()
            if command[0] == 'cd':
                directory_name = command[1]
                if directory_name == '..':
                    fs.current_directory = fs.current_directory.parent
                elif directory_name == '/':
                    fs.current_directory = fs.root
                else:
                    for subdirectory in fs.current_directory.subdirectories:
                        if subdirectory.name == directory_name:
                            fs.current_directory = subdirectory
                            break
            elif command[0] == 'ls':
                # Parse subdirectories and files
                while True:
                    i = i + 1
                    if i >= len(lines):
                        break
                    child = lines[i]
                    if child.startswith('$'):
                        i = i - 1
                        break
                    if child.startswith('dir'):
                        subdirectory_name = child[4:].strip()
                        subdirectory = Directory(subdirectory_name, fs.current_directory)
                        fs.current_directory.subdirectories.append(subdirectory)
                    else:
                        child_file_details = child.split()
                        child_file = File(child_file_details[1], int(child_file_details[0]), fs.current_directory)
                        fs.current_directory.files.append(child_file)
        i = i + 1


# Get all directories with their size
def get_all_subdirectories(directory):
    subdirectories = []
    for subdirectory in directory.subdirectories:
        subdirectories.append(subdirectory)
        subdirectories.extend(get_all_subdirectories(subdirectory))
    return subdirectories

all_subdirectories = get_all_subdirectories(fs.root)
# Get all directories with size < 100000
small_directories = [directory for directory in all_subdirectories if directory.get_size() < 100000]
# Get sum of small_directories
print(sum([directory.get_size() for directory in small_directories]))

# Part 2
used_space = fs.root.get_size()
total_space = 70000000
free_space_required = 30000000
space_to_clear = used_space - total_space + free_space_required
# Find directories > free_space_required
eligible_deletion_directories = [directory for directory in all_subdirectories if directory.get_size() > space_to_clear]
# Find smallest eligible directory
smallest_eligible_directory = min(eligible_deletion_directories, key=lambda directory: directory.get_size())
print(f"Size of directory to delete: {smallest_eligible_directory.get_size()}")