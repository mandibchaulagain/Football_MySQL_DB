import os

def extract_file_names(directory):
    # List all files in the directory
    files = os.listdir(directory)
    
    # Filter out directories and get the filenames without extensions
    file_names = [os.path.splitext(file)[0] for file in files if os.path.isfile(os.path.join(directory, file))]
    
    # Join the file names into a string separated by commas
    return ', '.join(file_names)

# Example usage
directory_path = 'db\migrations'  # Current directory
file_names_string = extract_file_names(directory_path)
print(file_names_string)
