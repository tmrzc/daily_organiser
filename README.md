# daily_organiser / track.

Productivity app for keeping track of daily tasks and measuring our progress.

## VIDEO DEMO: https://youtu.be/vM6e2jdYNqw

## TECHNOLOGY USED: Flutter, Dart, SQL, SQLite

## HOW TO UNZIP FILES:

To correctly unpack project files you need to unzip files **dg_part1.zip**, **dg_part2.zip** and **dg_part3.zip** in the same directory. Then go to 

    \DIRECTORY\build\app\intermediates

and unzip here **intermediates_part1.zip**, **intermediates_part2.zip** and **intermediates_part3.zip**

## DESCRIPTION:

### App designed for productivity for mobile devices and to help me with daily journaling. I used Flutter framework so it should work both on iOS devices aswell android, but i only tested Android. 

#### It has **three** main functionalities. 

First one is a **TO-DO** list. You can add your tasks and they are displayed as a list with checkboxes. 
You can also create recursive tasks that will add automatically accordingly. It will help you with consistantly accomplishing set goals.

Second one are **TRACKERS**. You can create a tracker with custom name and selected input like stars, counters and a slider. Every day you can submit a score for every tracker and it is saved in a database.
This way you can measure your activities and track progress you want to. To analize your progress and see submitted values you can navigate to STATISTICS screen where data will be displayed using charts.

The last one is **JOURNAL**. Here is a simple journal for you to write down your thoughts. You can create a single note every day. It is meant to be a journal not a notepad.

Application is written using Flutter framework and its community's packages. To store data I used SQL database with sqflite Flutter package.