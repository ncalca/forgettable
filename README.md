Forgettable
===========

[![Build Status](https://travis-ci.org/ncalca/forgettable.svg?branch=master)](https://travis-ci.org/ncalca/forgettable) [![Code Climate](https://codeclimate.com/github/ncalca/forgettable/badges/gpa.svg)](https://codeclimate.com/github/ncalca/forgettable)
[![Gem Version](https://badge.fury.io/rb/forget_table.svg)](http://badge.fury.io/rb/forget_table)

Forgettable helps you find the probability of non-stationary categorical distributions.
To put it simply, you can find the most "popular" items in a stream of events, when their popularity changes unpredictably.


## Why?

Imagine you have a web application in which your users can create a post and comment on it. Finding the "hottest" posts might be simply achieved by finding the most commented posts or most recently commented posts.

While these solution are simple to implement and work in many cases, they have some drawbacks. For example a post with a lot of _old_ comments might be still reported as popular although nobody is actually commenting/reading it anymore. Or using the last commented time might generate a very unstable/fast changing list of "hottest" posts which does not really capture the trends among posts.

The main problem with these approaches is that consider old data as important as the new data: they don't forget.

Forgettable gives you a simple way to keep track of the most recent "trends" and smoothly forget about the past facts.

Forgettable is heavily inspired by [Forget-Table](https://github.com/bitly/forgettable), developed at [bitly](https://bitly.com).



## How to use Forgettable?

###### Creating a new distribution
The main concept used in Forgettable is a distribution which is initialised with a name and a Redis client:


```ruby
popular_guitars = ForgetTable::Distribution.new(name: "guitars", redis: redis)
```


###### Incrementing a bin
A distribution is a container of "bins", i.e., items we want to track.
In order to insert a new item we just use the `increment` method and pass the name of the bin we want to increment and the amount:


```ruby
popular_guitars.increment(bin: "fender", amount: 100)
```
If not specified, the amount defaults to 1:

```ruby
popular_guitars.increment(bin: "gibson")
```

###### Getting the probability distribution
Once bins are inserted in the distribution we can fetch the list of bins sorted by popularity:

```ruby
popular_guitars.distribution
=> ["fender", "gibson"]
```

Weights for the bins can be retrieved by setting the optional argument `with_scores` to true:

```ruby
popular_guitars.distribution(with_scores: true)
=> [["fender", 63.0], ["gibson", 1.0]]
```


###### Getting the probability for a given bin
You can also retrieve the score for a single bin:

```ruby
popular_guitars.score_for_bin("fender")
=> [30]
```


###### References
- Forgettable [project page](http://bitly.github.io/forgettable/)
- Some [optimizations](https://www.facebook.com/notes/kent-beck/forgettable-a-data-structure-for-tracking-recent-activity/532685556764313) to forgettable by Kent Beck.

=========

This software is release under the MIT [license](http://opensource.org/licenses/MIT).
