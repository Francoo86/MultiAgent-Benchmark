import os
import glob
import shutil
import re
from datetime import datetime

def get_latest_file(directory, scenario):
    """Find the latest file for a specific scenario in the directory."""
    # Pattern to match files with timestamps
    pattern = os.path.join(directory, f"rtt_measurements_{scenario}_*.csv")
    files = glob.glob(pattern)
    
    if not files:
        print(f"No files found for {scenario} in {directory}")
        return None
    
    # Extract datetime from filename and find the latest
    latest_file = None
    latest_time = datetime.min
    
    for file in files:
        # Extract date and time from filename using regex
        match = re.search(r"(\d{8})_(\d{6})", os.path.basename(file))
        if match:
            date_str, time_str = match.groups()
            try:
                file_time = datetime.strptime(f"{date_str}_{time_str}", "%Y%m%d_%H%M%S")
                if file_time > latest_time:
                    latest_time = file_time
                    latest_file = file
            except ValueError:
                print(f"Could not parse datetime from file: {file}")
    
    return latest_file

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

def main():
    # Define base directories
    jade_dir = os.path.join(CURRENT_DIR, "JADE_Output", "rtt_logs")
    spade_dir = os.path.join(CURRENT_DIR, "SPADE_Output", "rtt_logs")
    target_dir = "rtt"
    
    # Scenarios to process
    scenarios = ["small", "medium", "full"]
    
    # Process JADE files
    for scenario in scenarios:
        # Create scenario subdirectory if it doesn't exist
        scenario_dir = os.path.join(target_dir, scenario)
        os.makedirs(scenario_dir, exist_ok=True)
        
        current_scenario_dir = os.path.join(jade_dir, scenario)
        
        latest_file = get_latest_file(current_scenario_dir, scenario)
        if latest_file:
            new_filename = "jade.csv"
            target_path = os.path.join(scenario_dir, new_filename)
            shutil.copy2(latest_file, target_path)
            print(f"Copied {latest_file} to {target_path}")
    
    # Process SPADE files
    for scenario in scenarios:
        # Create scenario subdirectory if it doesn't exist
        scenario_dir = os.path.join(target_dir, scenario)
        os.makedirs(scenario_dir, exist_ok=True)
        
        current_scenario_dir = os.path.join(spade_dir, scenario)
        
        latest_file = get_latest_file(current_scenario_dir, scenario)
        if latest_file:
            new_filename = "spade.csv"
            target_path = os.path.join(scenario_dir, new_filename)
            shutil.copy2(latest_file, target_path)
            print(f"Copied {latest_file} to {target_path}")

if __name__ == "__main__":
    main()