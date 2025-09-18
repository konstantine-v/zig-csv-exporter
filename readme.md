## CSV Parse Test
Using the Kaggle dataset for student records: https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data


The idea for this was to practice using Zig and learn how to use it in a sort of real scenario for parsing data.

The data is read, parsed to how I wanted it, then output in the terminal. 

The output file is more compact reducing the size from ~550Kb -> ~320Kb. 

## Prerequisites
- Zig 0.14.1 (latest as of Sept 2025)
- CSV file (the one from Kaggle) -> `students.csv`

### Example Input
```
0,group B,bachelor's degree,1,0,72,72,74,218,72.66666666666667
0,group C,some college,1,1,69,90,88,247,82.33333333333333
0,group B,master's degree,1,0,90,95,93,278,92.66666666666667
1,group A,associate's degree,0,0,47,57,44,148,49.333333333333336
1,group C,some college,1,0,76,78,75,229,76.33333333333333
...
```

### Example Output
```
106046538, 158428504, 114733021, 562814124, 693315403, 97642958, 91631580, 621417895, 749740099, 76127794, 701406004, 768219691, 80767177, 561226822, 46963386, 139552206, 685124822, 67407900...
```
This allows for a more optimized size which is better for when reading it and storing in a db or whatever a user would want.

### Execution Time
I can run the program and it takes about `0.083` total seconds to run on my machine.
```
./main  0.03s user 0.06s system 98% cpu 0.083 total
```

### Compression
The data is being compressed for better storage of data by taking the input values, storing as correct unisigned integer values, then turning that data into a hex value. Further Compression can be done via gzip and other methods.

`56.6kB -> 10.9kB`

### Changelog
- 2025-09-03: compressing output data to hex value
- 2025-09-03: Updated code to work with the latest Zig version

### Notes
The code needs some obvious improvements but this is mainly so I can learn and improve as I learn.