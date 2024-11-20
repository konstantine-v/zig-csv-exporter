## CSV Parse Test
Using the Kaggle dataset for student records: https://www.kaggle.com/datasets/muhammadroshaanriaz/students-performance-dataset-cleaned/data

The idea for this was to practice using Zig and learn how to use it in a sort of real scenario for parsing data.

The data is read, parsed to how I wanted it, then output in the terminal.

Ideally this output would be exported back as a csv or be put into a database.

### Execution time
Parsing around 13k lines in around 0.4s on my machine.
```
Milliseconds      : 393
Ticks             : 3934375
TotalSeconds      : 0.3934375
TotalMilliseconds : 393.4375
```

### Example
```
Student: gender=true, eth=2, edu=1, lunch=false, test_prep=false, math=62, read=55, write=55, total=172
Student: gender=false, eth=2, edu=1, lunch=false, test_prep=true, math=59, read=71, write=65, total=195
Student: gender=false, eth=3, edu=2, lunch=true, test_prep=true, math=68, read=78, write=77, total=223
Student: gender=false, eth=3, edu=2, lunch=false, test_prep=false, math=77, read=86, write=86, total=249
```