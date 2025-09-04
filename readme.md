## CSV Parse Test
Using the Kaggle dataset for student records: https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data


The idea for this was to practice using Zig and learn how to use it in a sort of real scenario for parsing data.

The data is read, parsed to how I wanted it, then output in the terminal. 

The output file is more compact reducing the size from ~550Kb -> ~320Kb. 

## Prerequisites
- Zig 0.14.1 (latest as of Sept 2025)
- CSV file (the one from Kaggle) -> `students.csv`

### Example Output
```
true,3,1,false,false,44,51,48,143
false,4,2,true,true,86,85,91,262
false,4,3,true,false,85,92,85,262
false,0,5,false,false,50,67,73,190
```
This allows for a more optimized size which is better for when reading it and storing in a db or whatever a user would want.

### Execution Time
I can run the program and it takes about `0.083` total seconds to run on my machine.
```
./main  0.03s user 0.06s system 98% cpu 0.083 total
```

### Notes
The code needs some obvious improvements but this is mainly so I can learn and improve as I learn.

### Changelog
- 2025-09-03: Updated code to work with the latest Zig version

### Future Improvements
- Add a CLI interface to specify input and output files
- Improve memory management
- Compression on the ouput file