## CSV Parse Test
Using the Kaggle dataset for student records: https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data

The idea for this was to practice using Zig and learn how to use it in a sort of real scenario for parsing data.

The data is read, parsed to how I wanted it, then output in the terminal. 

The output file is more compact reducing the size from ~550Kb -> ~320Kb. 

### Example Output
```
true,3,1,false,false,44,51,48,143
false,4,2,true,true,86,85,91,262
false,4,3,true,false,85,92,85,262
false,0,5,false,false,50,67,73,190
```
This allows for a more optimized size which is better for when reading it and storing in a db or whatever a user would want.

### Execution Time
I modified the csv to be 10k lines and have it running under a second while writing to a new file. When writing to debug print it's much slower.

```
Milliseconds      : 866
Ticks             : 8669053
TotalDays         : 1.00336261574074E-05
TotalHours        : 0.000240807027777778
TotalMinutes      : 0.0144484216666667
TotalSeconds      : 0.8669053
TotalMilliseconds : 866.9053
```

### Notes
The code needs some obvious improvements but this is mainly so I can learn and improve as I learn.

Next improvements will be
- Add a CLI interface to specify input and output files
- Improve memory management, GPA might not be the best option
- Made code improvements like switchcases and whatnot
- Compression on the ouput file