## CSV Parse Test
Using the Kaggle dataset for student records: https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data

The idea for this was to practice using Zig and learn how to use it in a sort of real scenario for parsing data.

The data is read, parsed to how I wanted it, then output in the terminal.

Ideally this output would be exported back as a csv or be put into a database.

### Example Output
```
Student: gender=true, eth=2, edu=1, lunch=false, test_prep=false, math=62, read=55, write=55, total=172
Student: gender=false, eth=2, edu=1, lunch=false, test_prep=true, math=59, read=71, write=65, total=195
Student: gender=false, eth=3, edu=2, lunch=true, test_prep=true, math=68, read=78, write=77, total=223
Student: gender=false, eth=3, edu=2, lunch=false, test_prep=false, math=77, read=86, write=86, total=249
```

### Execution Time
I modified the csv to be 10k lines and have it running under a second while writing to a new file. When writing to debug print it's much slower.

```
Milliseconds      : 905
Ticks             : 9050106
TotalDays         : 1.04746597222222E-05
TotalHours        : 0.000251391833333333
TotalMinutes      : 0.01508351
TotalSeconds      : 0.9050106
TotalMilliseconds : 905.0106
```

### Notes
The code needs some obvious improvements but this is mainly so I can learn and improve as I learn