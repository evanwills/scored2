# `Scored` (with lit on Deno)

## About `Scored`

`Scored` is an app to let you score your favourite games. My usecase is to score family games of [500](https://en.wikipedia.org/wiki/500_(card_game)) and [Crazy Eights](https://en.wikipedia.org/wiki/Crazy_eights) and to record, for prosterity, the history of all the games played.

## Features

* [Local-first](https://www.inkandswitch.com/local-first/): The app (once loaded) will work regardless of internet connection. (All data will be stored locally on the device in [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API))
* Will come with a number of predefined scoring algorithms for different games.<br />
  Initially:
  * [500](https://en.wikipedia.org/wiki/500_(card_game)) 
  * [Crazy Eights](https://en.wikipedia.org/wiki/Crazy_eights) 
  * Generic individual player game 
  * Generic teams game
* Handles both individual player and team games
* Stores the full scoring record for each game
* Has individual player management and team management
* Allows for custom scoring rules so user can set up scoring rules for their own games
* Allows for storing and resuming interrupted games.

## Local-first

Currently is is an off-line/[local-first](https://www.inkandswitch.com/local-first/) only app meaning that _**all**_ your data exists on your device (and only that device). 

### Useful local-first

Initially `Scored` will be annoyingly isolated, my focus will be on getting basic scoring and local data storage working so there will be no data syncing across devices. This will be very annoying and not super useful. Once I've got all the main functionality working, I will implement some sort of data syncing so data can be shared between devices.

I will also implement data import/export via JSON so you can back up your data.